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
  task :bootstrap => ['duroosi:db:migrate', 'db:seed', 'duroosi:redis:reset' ]

  desc 'Saves the content of both redis and database into backup files.'
  task :backup => ['duroosi:db:backup', 'duroosi:redis:backup']

  desc 'Restore the content of both redis and database from backup files.'
  task :restore => ['duroosi:db:migrate', 'duroosi:redis:clear', 'duroosi:db:restore', 'duroosi:redis:restore']
end
