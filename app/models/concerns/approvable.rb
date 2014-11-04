module Approvable
  extend ActiveSupport::Concern

  included do
  end

  def approved? 
    active && approved_at.present?
  end
  
  def approve
    self.update(active: true, approved_at: Time.zone.now, suspended_at: nil, cancelled_at: nil)
  end
end