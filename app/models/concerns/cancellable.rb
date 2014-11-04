module Cancellable
  extend ActiveSupport::Concern

  included do
  end

  def cancelled? 
    !active && suspended_at.present?
  end
  
  def cancel
    self.update(active: false, cancelled_at: Time.zone.now, suspended_at: nil)
  end
end