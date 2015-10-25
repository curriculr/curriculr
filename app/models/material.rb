class Material < ActiveRecord::Base
  include Actionable
  acts_as_taggable_on :tags

  belongs_to :owner, :polymorphic => true#, :counter_cache => true
  belongs_to :medium

	# Validation Rules
	validates :kind, :presence => true

  def course
    medium.course
  end

  def of_content_type?(type)
    medium.content_type.present? && medium.content_type.include?(type)
  end

  def at_url(version = nil)
    self.medium.at_url(version) if self.medium
  end
end
