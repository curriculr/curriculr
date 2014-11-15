namespace :duroosi do  
  namespace :redis do
    #desc "Flush all redis content"
    task :flush do
      $redis.flushall
      puts 'Redis flushed successfully.'
    end

    desc "Restores redis's original configurations and translations."
    task :reset => :environment do   
      Rake::Task["duroosi:redis:clear"].invoke 

      config = YAML.load_file("#{Rails.root}/config/config-account.yml")
      accounts = Account.all
      accounts.each do |a|
        $redis.set "config.account.#{a.slug}", config['account'].to_json
      end
    
      config = YAML.load_file("#{Rails.root}/config/config-course.yml")
      courses = Course.unscoped.all
      courses.each do |c|
        $redis.set "config.course.#{c.account.slug}_#{c.id}", config['course'].to_json
      end
    
      $site['supported_locales'].each do |locale, name|
        ['account.'].each do |part| # Full array: ['', 'config.', 'account.', 'model.']
          filename = "#{Rails.root}/config/locales/#{part}#{locale}.yml"
          puts "loading #{filename} ..."
          yml_t = YAML.load_file(filename)

          out_t = {}
          Translator.from_yaml(locale, out_t, yml_t, '')
        
          translations = Hash[out_t.map { |k, v| [k.sub('account.site.', 'main.site.'), v] }]
          I18n.backend.store_translations( locale, translations, :escape => false )
        end
      end
    
      puts 'Redis reset successfully.'
    end

    desc "Backs up the content redis into db/backup_redis.yml."
    task :backup => :environment do
      file = "#{Rails.root}/db/backup_redis.yml"
      if File.exists?(file)
        `mv #{file} #{Rails.root}/db/backup_redis-#{Time.zone.today.strftime('%F')}.yml`
      end

      data = {:config => {}, :i18n => {}}
      $redis.keys("*").each do |k|
        data[:config][k] = JSON.parse($redis.get(k))
      end

      $site['supported_locales'].each do |locale, v|
        data[:i18n][locale] = {}

        Translator.store.keys("#{locale}.*").each do |k|
          data[:i18n][k] = Translator.store.get(k)
        end
      end

      File.open(file, "w") do |file|
        file.write data.to_yaml
      end

      puts 'Redis backed up successfully.'
    end

    #desc "Clears configurations and translations."
    task :clear => :environment do
      $site['supported_locales'].each do |locale, v|
        Translator.store.keys("#{locale}.*").each do |k|
          Translator.store.del(k)
        end
      end

      $redis.keys("*").each do |k|
        $redis.del(k)
      end
    end

    desc "Restores the content of redis from a given yml file."
    task :restore => :environment do
      filename = "#{Rails.root}/db/backup_redis.yml"
      if File.exists?(filename)
        data = YAML.load_file(filename)
      
        config = data[:config]
        config.each do |k, v|
          $redis.set(k, v.to_json)
        end

        translations = data[:i18n]
        translations.each do |k, v|
          Translator.store.set(k, v)
        end

        puts 'Redis successfully restored.'
      end
    end
  end
end
