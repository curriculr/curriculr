# encoding: utf-8

class InstructorAvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  VERSIONS = { med: 200, sml: 100, th: 48, tny: 21 }

  # What kind of storage to use for this uploader (:file or :fog)
  storage Rails.application.secrets.storage['type'].to_sym

  # The directory where uploaded files will be stored.
  def store_dir
    "#{Rails.application.secrets.database['name']}/c/i/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :med do
    process :resize_to_limit => [VERSIONS[:med], VERSIONS[:med]]
  end

  version :sml do
    process :resize_to_limit => [VERSIONS[:sml], VERSIONS[:sml]]
  end
  
  version :th do
    process :resize_to_fill => [VERSIONS[:th], VERSIONS[:th]]
  end
  
  version :tny do
    process :resize_to_fill => [VERSIONS[:tny], VERSIONS[:tny]]
  end
  
  # White list of extensions which are allowed to be uploaded.
  def extension_white_list
     %w(jpg jpeg gif png)
  end

  # Filename of the uploaded files:
  def filename
    "#{Digest::MD5.hexdigest(original_filename)}.#{file.extension}" if original_filename
  end
end
