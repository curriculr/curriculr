class KlassUpdatesJob < ApplicationJob
  include EditorsHelper
  queue_as :default

  def perform(*args)
    keep_running = args[0] || false
    config = {}
    Klass.active.open.each do |klass|
      # Step 1: Generate klass updates from course and unit updates
      course = klass.course

      # Course updates
      updates = course.updates.where(active: true, www: true).
        where('not exists(select u.generator_id from updates u where u.generator_id = updates.id and u.klass_id = :klass_id)', :klass_id => klass.id)

      updates.each do |update|
        new_update = update.dup
        new_update.course_id = nil
        new_update.unit_id = nil
        new_update.email = false # Email course updates will be sent after initial enrollments
        new_update.klass_id = klass.id
        new_update.generator_id = update.id
        new_update.save!
      end

      # Unit updates
      Unit.open(klass, Student.find_by(user: klass.course.originator)).each do |unit|
        updates = unit.updates.where(active: true).
          where('not exists(select u.generator_id from updates u where u.generator_id = updates.id and u.klass_id = :klass_id)', :klass_id => klass.id)
          
        updates.each do |update|
          new_update = update.dup
          new_update.course_id = nil
          new_update.unit_id = nil
          new_update.klass_id = klass.id
          new_update.generator_id = update.id
          new_update.save!
        end
      end

      # Step 2: Post/send klass updates that have not been posted/sent yet.
      account = Account.find(klass.account_id)
      config[account.slug] ||= JSON.parse($redis.get("config.account.a#{account.id}"))

      students = klass.students.joins(:user).where('enrollments.active = TRUE').
        select('users.name as user_name, users.email as user_email, students.name as student_name')

      instructors = klass.instructors
      klass.updates.where(active: true, sent_at: nil).where('generator_id is not null').each do |update|
        if update.email
          body = markdown(update.body)
          body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

          students.map do |s|
            Mailer.klass_update(
              account.slug, 
              Rails.application.secrets.mailer[:noreply], 
              s.user_email, 
              update.subject, 
              body, klass.id
            ).deliver_later
          end
        end

        update.sent_at = Time.zone.now
        update.save
      end
    end

    # Run this again after two minutes
    KlassUpdatesJob.set(wait: 2.minutes).perform_later(true) if keep_running
  end
end
