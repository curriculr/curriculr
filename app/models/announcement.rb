class Announcement < ActiveRecord::Base
  include Scopeable
  belongs_to :user
  
  validates :message, :starts_at, :ends_at, :presence => true
  validate :proper_start_and_end_datetimes

  def proper_start_and_end_datetimes    
    if ends_at.present? and starts_at >= ends_at
      errors.add :ends_at, :must_be_after_start_date
    end 
  end 
  def self.current(hidden_ids = nil)
    result = scoped.where("suspended = FALSE and starts_at <= :now and ends_at >= :now", now: Time.zone.now)
    result = result.where("id not in (?)", hidden_ids) if hidden_ids.present?
    result
  end
end
