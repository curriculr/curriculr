namespace :curriculr do  
  namespace :assets do
    desc "Compile all the assets named in config.assets.precompile and runs css-flip to support RTL."
    task :precompile => :environment do
      # Make sure you have css-flip installed
      Dir.chdir Rails.root 
      `npm install css-flip`

      # Generate en assets
      assets_path = "#{Rails.root}/public/assets"
      `rm -rf #{Rails.root}/public/assets/*`
      %w(red blue green vanilla).each do |flavor|
        `rm -f #{Rails.root}/app/assets/stylesheets/bootstrap/#{flavor}_rtl.css`
      end
      Rake::Task["assets:precompile"].execute


      # Identify and locate the en assets that will be css-flipped
      Dir.chdir "#{assets_path}/bootstrap"
      assets = %w(red blue green vanilla).map do |flavor|
        [flavor, %(#{assets_path}/bootstrap/#{Dir.glob("#{flavor}-*.css").first})]
      end

      # Css-flip the indentifed en assets
      Dir.chdir Rails.root
      assets.each do |asset|
        puts "Runnig : ./bin/cssflip.sh bootstrap #{asset[0]} #{asset[1]}"
        `./bin/cssflip.sh bootstrap #{asset[0]} #{asset[1]}`
      end

      # Done
      puts "Assets compiled successfully."
    end
  end
end
