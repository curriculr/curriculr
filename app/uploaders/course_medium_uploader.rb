# encoding: utf-8

class CourseMediumUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # What kind of storage to use for this uploader (:file or :fog)
  storage Rails.application.secrets.storage['type'].to_sym

  # The directory where uploaded files will be stored.
  def store_dir
    "#{Rails.application.secrets.database['name']}/c/m/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :md, :if => :image? do
    process :resize_to_fill => [300, 169]
  end

  version :sm, :if => :image? do
    process :resize_to_fill => [240, 135]
  end

  def image?(new_file)
    model.of_kind?('image')
  end

  # White list of extensions which are allowed to be uploaded.
  def extension_white_list
    model.allowed_file_extensions
  end

  # Filename of the uploaded files:
  def filename
    "#{Digest::MD5.hexdigest(original_filename)}.#{file.extension}" if original_filename
  end

  def filename_original
    original_filename
  end
end
