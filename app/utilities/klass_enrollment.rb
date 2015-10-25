class KlassEnrollment
  def self.staff?(user, course_or_klass)
    return false if user.blank? || course_or_klass.blank?

    course = course_or_klass.kind_of?(Klass) ? course_or_klass.course : course_or_klass

    user && course && (
      user.has_role?(:admin) || (
        user.has_role?(:faculty) && course.originator_id == user.id
      ) || course.instructors.map(&:user_id).include?(user.id)
    )
  end

  def self.enroll(klass, student, invitation_only = false)
    return nil if klass.blank? || student.blank?

    if !klass.enrolled?(student) && !staff?(student.user, klass.course)
      enrollment =  klass.enrollments.where(:student_id => student.id).first_or_initialize
      return enrollment if enrollment.active

      to_activitate = if klass.private
        if invitation_only
          enrollment.invited_at = Time.zone.now
          false
        else
          if enrollment.invited_at.present? && enrollment.accepted_or_declined_at.blank?
            enrollment.accepted_or_declined_at = Time.zone.now
            true
          else
            false
          end
        end
      elsif enrollment.new_record?
        true
      elsif enrollment.dropped_at.present?
        enrollment.dropped_at = nil
        true
      elsif enrollment.suspended_at.present?
        enrollment.suspended_at = nil
        true
      else
        false
      end

      enrollment.active = true if to_activitate
      enrollment.save!

      return enrollment
    end

    nil
  end

  def self.drop(enrollment)
    unenroll(enrollment, [:drop])
  end

  def self.decline(enrollment)
    unenroll(enrollment, [:decline])
  end

  def self.suspend(enrollment)
    unenroll(enrollment, [:suspend])
  end

  def self.unenroll(enrollment, actions = [:drop])
    return false if enrollment.blank? || (!enrollment.active && !actions.include?(:decline))

    enrollment.transaction do
      enrollment.active = false
      enrollment.dropped_at = Time.zone.now if actions.include?(:drop)
      enrollment.accepted_or_declined_at = Time.zone.now if actions.include?(:decline)
      enrollment.suspended_at = Time.zone.now if actions.include?(:suspend)

      return true if enrollment.save!
    end

    false
  end
end
