OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  [:facebook, :google_oauth2].each do |app|
    provider app, Rails.application.secrets.auth[app][:id], Rails.application.secrets.auth[app][:secret]
  end
end
