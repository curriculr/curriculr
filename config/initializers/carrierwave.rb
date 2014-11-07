CarrierWave.configure do |config|
  case Rails.application.secrets.storage['type']
  when 'file'
    config.asset_host = Rails.application.secrets.storage['asset_host']
  when 'fog'
    if Rails.application.secrets.storage['fog']
      if Rails.application.secrets.storage['fog']['AWS']
        config.fog_credentials = Rails.application.secrets.storage['fog']['AWS'].merge(provider: 'AWS')
      elsif Rails.application.secrets.storage['fog']['Rackspace']
        config.fog_credentials = Rails.application.secrets.storage['fog']['Rackspace'].merge(provider: 'Rackspace')
      elsif Rails.application.secrets.storage['fog']['Google']
        config.fog_credentials = Rails.application.secrets.storage['fog']['Google'].merge(provider: 'Google')
      end

      config.fog_directory  = Rails.application.secrets.storage['fog']['directory'] # required
      config.fog_public     = Rails.application.secrets.storage['fog']['public']    # optional
      config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
    end
  end
end