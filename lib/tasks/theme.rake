namespace :curriculr do  
  namespace :theme do
    desc "Adds a brand new theme supplied by THEME=? ABOUT=?."
    task :new => :environment do
      if ENV['THEME'].present?
        theme = ENV['THEME'].downcase
        if %w(bootstrap).include?(theme)
          puts "Default bootstrap theme is already available and cannot be added."
        else
          about = ENV['ABOUT'] || theme
          %w(/app/assets/javascripts/ /app/assets/stylesheets/ /app/views/themes/ /app/helpers/themes/).each do |directory|
            dirpath = "#{Rails.root}#{directory}#{theme}"
            Dir.mkdir(dirpath) unless Dir.exist?(dirpath)
          end

          unless $site['available_themes'].has_key?(theme)
            $site['available_themes'][theme] = { 'parent' => 'bootstrap', 'about' => about }
            $redis.set "config.site", $site.to_json 
          end
        end
      else
        puts "No theme to add. try 'rake curriculr:theme:new THEME=? ABOUT=?'."
      end
    end

    desc "Deletes an existing theme indentified by THEME=?."
    task :delete => :environment do
      if ENV['THEME'].present?
        theme = ENV['THEME'].downcase
        if %w(bootstrap).include?(theme)
          puts "Default bootstrap theme cannot be deleted."
        else
          %w(/app/assets/javascripts/ /app/assets/stylesheets/ /app/views/themes/ /app/helpers/themes/).each do |directory|
            dirpath = "#{Rails.root}#{directory}#{theme}"
            FileUtils.remove_dir(dirpath, true) if Dir.exist?(dirpath)
          end

          if $site['available_themes'].has_key?(theme)
            $site['available_themes'].delete(theme)
            $redis.set "config.site", $site.to_json 
          end
        end
      else
        puts "No theme to delete. try 'rake curriculr:theme:delete THEME=?'."
      end
    end
  end
end
