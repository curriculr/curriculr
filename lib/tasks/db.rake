namespace :duroosi do  
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
end

