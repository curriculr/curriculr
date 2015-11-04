Devise.setup do |config|
  config.mailer = "Mailer"

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours

  # ==> Scopes configuration
  config.scoped_views = true
  config.sign_out_via = :delete

  # ==> OmniAuth
  silence_warnings do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE unless Rails.env.production? 
  end
  %w(facebook google_oauth2 twitter linkedin github).each do |app|
    if Rails.application.secrets.auth[app]
      config.omniauth app,
        Rails.application.secrets.auth[app]['id'],
        Rails.application.secrets.auth[app]['secret']
    end
  end
end
