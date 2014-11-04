CarrierWave.configure do |config|
  if Rails.application.secrets.storage['type'] == 'file'
    config.asset_host = Rails.application.secrets.storage['asset_host'] 
  end
  
  config.fog_credentials = {
    :provider               => 'AWS',                        
    :aws_access_key_id      => Rails.application.secrets.storage['fog']['aws']['access-key-id'],                        
    :aws_secret_access_key  => Rails.application.secrets.storage['fog']['aws']['secret-access-key'],                        
    :region                 => Rails.application.secrets.storage['fog']['aws']['region']
  }
  config.fog_directory  = Rails.application.secrets.storage['fog']['directory'] # required
  config.fog_public     = Rails.application.secrets.storage['fog']['public']    # optional
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end