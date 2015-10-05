class FacultyApplication < ActiveRecord::Base
  belongs_to :user

  validates :name, :about, :course, :description, :locale, :presence => true
	validates :weeks, :workload, :numericality => {:allow_blank => true, :only_integer => true, :greater_than => 0 }

  scope :pending, -> {
    where('approved = FALSE and declined_at is null')}

  scope :approved_or_pending, ->(user) {
    where("user_id = :user_id and (approved = TRUE or (approved = FALSE and declined_at is null))",
      :user_id => user.id)}

  def approved?
    approved
  end

  def pending?
    !approved && declined_at.blank?
  end
end
