Devise.setup do |config|
  # ==> Mailer Configuration
  config.mailer_sender = Rails.application.secrets.auth_mailer_sender
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
  require "omniauth-facebook"
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 
  config.omniauth :facebook, 
    Rails.application.secrets.auth['facebook']['id'], 
    Rails.application.secrets.auth['facebook']['secret']
  
  require "omniauth-google-oauth2"
  config.omniauth :google_oauth2, 
    Rails.application.secrets.auth['google']['id'], 
    Rails.application.secrets.auth['google']['secret']
end
