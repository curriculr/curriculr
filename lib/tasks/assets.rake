namespace :curriculr do  
  namespace :assets do
    desc "Compile all the assets named in config.assets.precompile and runs css-flip to support RTL."
    task :precompile => :environment do
      base_path = "#{Rails.root}/vendor/assets/stylesheets/semantic_ui"
      to_base_path = "#{base_path}/config"
      `mkdir #{to_base_path}` unless Dir.exist?(to_base_path)
      
      account = nil
      account = Account.find_by(slug: ENV['CURRENT_ACCOUNT']) if ENV['CURRENT_ACCOUNT']
      account = Account.find(1) unless account
      
      theme = account.config['theme']['name']
      if theme.present? && theme != 'sunshine' && !Dir.exist?("#{base_path}/themes/#{theme}")
        theme = 'sunshine'
      end
      
      # Copy theme files for preprocessing
      from_base_path = "#{base_path}/themes/#{theme}"
      `cp -R #{base_path}/themes/config/* #{to_base_path}/`
      `cp -R #{from_base_path}/* #{to_base_path}/`
      
      # Make sure you have css-flip installed
      Dir.chdir Rails.root 
      `npm install css-flip`

      # Generate en assets
      assets_path = "#{Rails.root}/public/assets"
      `rm -rf #{Rails.root}/public/assets/*`
      `rm -f #{Rails.root}/app/assets/stylesheets/sunshine/style_rtl.css`

      Rake::Task["assets:precompile"].execute

      # Identify and locate the en assets that will be css-flipped
      Dir.chdir "#{assets_path}"
      css_path =  %(#{assets_path}/#{Dir.glob("style-*.css").first})

      # Css-flip the indentifed en assets
      Dir.chdir Rails.root
      puts "Runnig cssflip for theme: #{theme}..."
      `./bin/cssflip.sh . style #{css_path}`
      
      # Clean after cssflip
      `cat #{base_path}/add_to_style_rtl.css >> #{Rails.root}/app/assets/stylesheets/style_rtl.css`
      
      # Done
      puts "RTL css for account #{account.slug} generated successfully. Run rails assets:precompile to finish."
    end
  end
end
