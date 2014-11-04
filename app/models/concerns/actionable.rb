module Actionable
  extend ActiveSupport::Concern

  included do
    has_many :activities, :as => :actionable, :dependent => :destroy
  end

  def log_activity(action, klass, student, name, points = 0, accumulate_points = false)
    a = self.activities.where(:action => action, :klass => klass, :student => student).first_or_initialize
    a.times = a.times + 1
    
    if accumulate_points
      a.points += points
    else
      a.points = points
    end
    a.save
  end
  
  def has?(action, klass, student) 
    self.activities.where(:student => student, :klass => klass, :action => action).any?
  end
end