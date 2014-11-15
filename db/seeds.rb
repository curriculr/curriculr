# Adding the site's super admin
if (su = User.find_by(id: 1)).blank?
  su = User.new
  email = Rails.application.secrets.site['su_email']
  su.email = email
  su.password = Rails.application.secrets.site['su_password']
  su.password_confirmation = Rails.application.secrets.site['su_password']
  su.name = Rails.application.secrets.site['su_name']
  su.skip_confirmation!

  su.save!
end

# Creating the site's main account
account = nil
if Account.where(:slug => $site['default_account']).to_a.empty?
  account = Account.create(
    :admin => su,
    :slug => $site['default_account'],
    :name => 'Default Account',
    :about => 'The default account of the site',
    :active => true,
    :live => true,
    :live_since => Time.zone.now
  )

  su.update(account_id: account.id)
end
