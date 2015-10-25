class Medium < ActiveRecord::Base
  include Scopeable
  acts_as_taggable_on :tags

  belongs_to :course, :counter_cache => true
  attr_accessor :is_a_link, :source, :m, :multi

  mount_uploader :path, CourseMediumUploader

	# Validation Rules
	validates :name, :kind, :presence => true
  validates :path, :presence => true, :if =>  Proc.new { |m| m.is_a_link == '0' }
  validates :url, :source, :presence => true, :if =>  Proc.new { |m| m.is_a_link == '1' }

  def at_url(version = nil)
    if path.present?
      version ? path_url(version) : path_url
    else
      #content_type == 'link/youtube' ? "//youtu.be/#{url}" : url
      url
    end
  end

  def full_url
    if self.kind == 'video' && (self.content_type =~ /link\/youtube/).present?
      "https//youtu.be/#{self.at_url}"
    else
      self.at_url
    end
  end

  def allowed_file_extensions
    config = course.present? ? course.config['allowed_file_types'] : account.config['allowed_file_types']
    [config['image'], config['video'], config['audio'], config['document'], config['other']].flatten
  end

  def kind_from_extension(extension)
    config = course.present? ? course.config['allowed_file_types'] : account.config['allowed_file_types']
    %w(image video audio document other).each do |kind|
      return kind if config[kind].include?(extension)
    end

    'other'
  end

  def of_kind?(kind)
    config = course.present? ? course.config['allowed_file_types'] : account.config['allowed_file_types']
    config[kind].include?(path.file.extension)
  end

  def file_upload_allowed?
    account.config['allow_file_uploads'] && (
      course.blank? || course.config['allow_file_uploads']
    )
  end

  # Callbacks
  after_initialize do
    self.is_a_link = !url.nil? if is_a_link.nil?
    if !new_record? && self.is_a_link
      self.source = content_type.split('/').last
    end
  end

  before_validation do |medium|
    if 'multi_load' == self.multi
      if path && path.file
        self.kind = kind_from_extension(path.file.extension)
        self.name ||= File.basename(path.filename_original, '.*').titleize
      end
    end
  end

  before_save :update_path_attributes

  before_destroy do |medium|
    Material.where(:medium => medium).destroy_all
  end

  private

  def update_path_attributes
    if path.present? && path_changed?
      self.content_type = path.file.content_type unless path.file.content_type.nil?
      self.file_size = path.file.size
    end
  end
end
