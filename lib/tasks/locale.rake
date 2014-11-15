namespace :duroosi do  
  namespace :locale do
    desc "Adds a brand new locale supplied by LOCALE=? NAME=?."
    task :new => :environment do
      if ENV['LOCALE'].present?
        locale = ENV['LOCALE'].downcase
        if %w(ar en).include?(locale)
          puts "Default :ar and :en locales are already available and cannot be added."
        else
          name = ENV['NAME'] || locale
          ['', 'config.', 'account.', 'model.'].each do |part|
            filename_from = "#{Rails.root}/config/locales/#{part}en.yml"
            filename_to = "#{Rails.root}/config/locales/#{part}#{locale}.yml"
            if File.exists?(filename_to)
              puts "File #{filename_to} already exists."
            else
              en_yml = YAML.load_file(filename_from)
              new_yml = { locale => {}}
              en_yml["en"].each do |k, v|
                new_yml[locale][k] = v
              end
               
              File.open(filename_to, "w") do |file|
                file.write new_yml.to_yaml
              end

              puts "File #{filename_to} added successfully."
            end
          end

          unless $site['supported_locales'].has_key?(locale)
            $site['supported_locales'][locale] = name
            $redis.set "config.site", $site.to_json 

            filename = "#{Rails.root}/config/locales/account.#{locale}.yml"
            yml_t = YAML.load_file(filename)
            out_t = {}
            Translator.from_yaml(locale, out_t, yml_t, '')
            
            translations = Hash[out_t.map { |k, v| [k.sub('account.site.', 'main.site.'), v] }]
            I18n.backend.store_translations( locale, translations, :escape => false )
          end
        end
      else
        puts "No locale to add. try 'rake duroosi:locale:new LOCALE=? NAME=?'."
      end
    end

    desc "Deletes an existing locale indentified by LOCALE=?."
    task :delete => :environment do
      if ENV['LOCALE'].present?
        locale = ENV['LOCALE'].downcase
        if %w(ar en).include?(locale)
          puts "Default :ar and :en locales cannot be deleted."
        else
          ['', 'config.', 'account.', 'model.'].each do |part|
            filename = "#{Rails.root}/config/locales/#{part}#{locale}.yml"
            if File.exists?(filename)
              File.delete(filename)
              puts "File #{filename} deleted successfully."
            end
          end

          if $site['supported_locales'].has_key?(locale)
            $site['supported_locales'].delete(locale)
            $redis.set "config.site", $site.to_json 

            keys = Translator.store.keys("#{locale}.*")
            keys.each do |k|
              Translator.store.del(k)
            end if keys.present?
          end
        end
      else
        puts "No locale to delete. try 'rake duroosi:locale:delete LOCALE=?'."
      end
    end
  end
end
