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
      `rm -f #{Rails.root}/app/assets/stylesheets/bootstrap/style_rtl.css`

      Rake::Task["assets:precompile"].execute

      # Identify and locate the en assets that will be css-flipped
      Dir.chdir "#{assets_path}/bootstrap"
      css_path =  %(#{assets_path}/bootstrap/#{Dir.glob("style-*.css").first})

      # Css-flip the indentifed en assets
      Dir.chdir Rails.root
      puts "Runnig cssflip for theme: bootstrap and flavor: #{ENV['THEME_FLAVOR'] || 'vanilla'}..."
      `./bin/cssflip.sh bootstrap style #{css_path}`
      
      # Done
      puts "RTL css generated successfully. Run rails assets:precompile to finish."
    end
  end
end
