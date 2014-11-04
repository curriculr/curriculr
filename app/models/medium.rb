class Medium < ActiveRecord::Base
  include Scopeable
  acts_as_taggable_on :tags
  
  belongs_to :course, :counter_cache => true 
  attr_accessor :is_a_link, :source, :m
  
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
  
  # Callbacks
  after_initialize do 
    self.is_a_link = !url.nil? if is_a_link.nil?
    if !new_record? and self.is_a_link
      self.source = content_type.split('/').last
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
