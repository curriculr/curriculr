module GlobalData
  def set_default_su_and_account
    if ($su = User.find_by(id: 1)).blank?
      $su = User.new
      $su.email = "su@bar.com"
      $su.password = 'secretive'
      $su.password_confirmation = 'secretive'
      $su.name = Rails.application.secrets.site['su_name']
      $su.skip_confirmation!

      $su.save!
    end
=begin
    if ($admin = User.find_by(id: 2)).blank?
      $admin = User.new
      $admin.email = "admin@bar.com"
      $admin.password = 'secretive'
      $admin.password_confirmation = 'secretive'
      $admin.name = Rails.application.secrets.site['su_name']
      $admin.skip_confirmation!

      $admin.save!
    end
=end
    # Creating the site's main account
    if ($account = Account.where(:slug => $site['default_account']).first).blank?
      $account = Account.create(
        :admin => $su,
        :slug => $site['default_account'],
        :name => 'Default Account',
        :about => 'The default account of the site',
        :active => true,
        :live => true,
        :live_since => Time.zone.now
      )

      config = YAML.load_file("#{Rails.root}/config/config-account_main.yml")

      $redis.set "config.account.a#{$account.id}", config['account'].to_json
  
      yml_t = YAML.load_file("#{Rails.root}/config/config-account.en.yml")
      out_t = {}
      locale = :en
      Translator.from_yaml(locale, out_t, yml_t, '')
  
      translations = Hash[out_t.map { |k, v| [k.sub('account.site.', 'main.site.'), v] }]
      I18n.backend.store_translations( locale, translations, :escape => false )
      
      $su.update(account_id: $account.id)
    end
    
    Account.current_id = $account.id if $account
  end
end