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

  desc 'Creates a new database, runs migrations, loads seeds data, and reset redis.'
  task :bootstrap => :environment do
    Rake::Task['duroosi:db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['duroosi:redis:reset'].invoke if Rails.application.secrets.redis_enabled
  end

  desc 'Saves the content of both redis and database into backup files.'
  task :backup => :environment do
    Rake::Task['duroosi:db:backup'].invoke
    Rake::Task['duroosi:redis:backup'].invoke if Rails.application.secrets.redis_enabled
  end

  desc 'Restore the content of both redis and database from backup files.'
  task :restore => :environment do
    Rake::Task['duroosi:db:migrate'].invoke
    Rake::Task['duroosi:redis:clear'].invoke if Rails.application.secrets.redis_enabled
    Rake::Task['duroosi:db:restore'].invoke
    Rake::Task['duroosi:redis:restore'].invoke if Rails.application.secrets.redis_enabled
  end
end
