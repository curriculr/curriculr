class Enrollment < ActiveRecord::Base
  include Actionable

  belongs_to :klass, :counter_cache => true
  belongs_to :student

  serialize :data


  def self.by(klass, student)
    return nil unless klass && student

    klass.enrollments.where(:student_id => student.id, :active => true).first
  end

  # Scopes
  scope :for, ->(course, user) {
    joins(:klass).joins(:student).where('klasses.course_id = :course_id and students.user_id = :user_id and enrollments.active = TRUE',
    :course_id => course.id, :user_id => user.id)
  }

  # callbacks
  after_create do
    if klass.private && self.invited_at.present?
      activity = 'invited'
    else
      klass.increment!(:active_enrollments)
      activity = 'enrolled'
    end

    log_activity(activity, klass, student)
  end

  after_update do |enrollment|
    unless self.saved_changes[:last_attended_at].present?
      activity = nil

      if self.active
        klass.increment!(:active_enrollments) if self.saved_changes[:active] && !self.saved_changes[:active][0]
      else
        klass.decrement!(:active_enrollments) if self.saved_changes[:active] && self.saved_changes[:active][0]
      end

      if enrollment.active
        if self.accepted_or_declined_at.present? && self.saved_changes[:accepted_or_declined_at] && self.saved_changes[:accepted_or_declined_at][0].blank?
          activity = 'accepted'
        end

        if enrollment.dropped_at.blank? && self.saved_changes[:dropped_at] && self.saved_changes[:dropped_at][0].present?
          activity = 'enrolled'
        end
      else
        if enrollment.dropped_at.present? && self.saved_changes[:dropped_at] && self.saved_changes[:dropped_at][0].blank?
          activity = 'dropped'
        end

        if enrollment.accepted_or_declined_at.present? && self.saved_changes[:accepted_or_declined_at] && self.saved_changes[:accepted_or_declined_at][0].blank?
          activity = 'declined'
        end

        if enrollment.suspended_at.present? && self.saved_changes[:suspended_at] && self.saved_changes[:suspended_at][0].blank?
          activity = 'suspended'
        end
      end

      if activity.present?
        log_activity(activity, klass, student)
      end
    end
  end

  def dropped?
    self.saved_changes[:active] && self.saved_changes[:active][0] && !self.saved_changes[:active][1] &&
    self.saved_changes[:dropped_at] && self.saved_changes[:dropped_at][0].nil? && self.saved_changes[:dropped_at][1].present?
  end
end
