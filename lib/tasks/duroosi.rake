namespace :duroosi do  
  namespace :secrets do
    desc "Generates a config/secrets.yml file if it doesn't already exist."
    task :generate do
      filename = "#{Rails.root}/config/secrets.yml"
      if File.exists?(filename)
        puts "File #{filename} already exists."
      else
        `cp #{Rails.root}/config/secrets_example.yml #{filename}`
        puts "File #{filename} generated successfully."
      end
    end
  end

  namespace :db do
    desc "Migrates the database. It the database doesn't exists, it creates it."
    task :migrate => [] do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["acts_as_taggable_on_engine:install:migrations"].invoke
      Rake::Task["db:migrate"].invoke

      puts 'Database migrated successfully.'
    end

    desc "Backs up the content (not structure) of the database into an db/backup_{adapter}.sql."
    task :backup => :environment do
      db_file = "#{Rails.root}/db/backup_#{Rails.application.secrets.database["adapter"]}.sql"
      if File.exists?(db_file)
        `mv #{db_file} #{Rails.root}/db/backup_#{Rails.application.secrets.database["adapter"]}-#{Time.zone.today.strftime('%F')}.sql`
      end

      if Rails.env.production? 
        db_name = Rails.application.secrets.database["name"]
      else
        db_name = "#{Rails.application.secrets.database["name"]}_development"
      end

      db_user = Rails.application.secrets.database["username"]
      

      if Rails.application.secrets.database["adapter"] == "postgresql"
        `pg_dump -a -T schema_migrations #{db_name} > #{db_file}`
      else
        options = "--no-create-info --ignore-table=#{db_name}.schema_migrations"
        `mysqldump -u #{db_user} -p #{db_name} #{options} > #{db_file}`
      end

      puts 'Database backed up successfully.'
    end

    desc "Restores the content (not structure) of the database from db/backup_{adapter}.sql."
    task :restore do
      if Rails.env.production? 
        db_name = Rails.application.secrets.database["name"]
      else
        db_name = "#{Rails.application.secrets.database["name"]}_development"
      end

      db_user = Rails.application.secrets.database["username"]
      db_file = "backup_#{Rails.application.secrets.database["adapter"]}.sql"

      if Rails.application.secrets.database["adapter"] == "postgresql"
        `psql #{db_name} < #{Rails.root}/db/#{db_file}` 
      else
        `mysql -u #{db_user} -p #{db_name} < #{Rails.root}/db/#{db_file}`
      end

      puts 'Database restored successfully.'
    end
  end

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
    
      [:en, :ar].each do |locale|
        puts "loading #{Rails.root}/config/config-account.#{locale}.yml ..."
        yml_t = YAML.load_file("#{Rails.root}/config/config-account.#{locale}.yml")

        out_t = {}
        Translator.from_yaml(locale, out_t, yml_t, '')
      
        translations = Hash[out_t.map { |k, v| [k.sub('account.site.', 'main.site.'), v] }]
        I18n.backend.store_translations( locale, translations, :escape => false )
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

      puts 'Redis cleared successfully.'
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

  desc 'Creates a new database, runs migrations, loads seeds data, and reset redis.'
  task :bootstrap => ['duroosi:db:migrate', 'duroosi:redis:clear', 'db:seed']

  desc 'Saves the content of both redis and database into backup files.'
  task :backup => ['duroosi:db:backup', 'duroosi:redis:backup']

  desc 'Restore the content of both redis and database from backup files.'
  task :restore => ['duroosi:db:migrate', 'duroosi:redis:clear', 'duroosi:db:restore', 'duroosi:redis:restore']
end
