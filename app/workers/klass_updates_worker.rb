class KlassUpdatesWorker
  include Sidekiq::Worker
  def perform()
    Klass.active.open.each do |klass|
      # Step 1: Generate klass updates from course and unit updates
      course = klass.course

      # Course updates
      updates = course.updates.where(active: true).
        where('id not in (select generator_id from updates where klass_id = :klass_id)', :klass_id => klass.id)

      updates.each do |update|
        new_update = update.dup
        new_update.course_id = nil
        new_update.unit_id = nil
        new_update.klass_id = klass.id
        new_update.generator_id = update.id
        new_update.save
      end

      # Unit updates
      Unit.open(klass, Student.find(1)).each do |unit|
        updates = unit.updates.where(active: true).
          where('id not in (select generator_id from updates where klass_id = :klass_id)', :klass_id => klass.id)
          
        updates.each do |update|
          new_update = update.dup
          new_update.course_id = nil
          new_update.unit_id = nil
          new_update.klass_id = klass.id
          new_update.generator_id = update.id
          new_update.save
        end
      end

      # Step 2: Post/send klass updates that have not been posted/sent yet.
      current_account = klass.account
      students = klass.students.joins(:user).where('enrollments.active = TRUE').
        select('users.name as user_name, users.email as user_email, students.name as student_name')

      instructors = klass.instructors
      klass.updates.where(active: true, sent_at: nil).where('generator_id is not null').each do |update|
        # generator = Update.find(update.generator_id)
        # if generator.course_id 
        update.sent_at = Time.zone.now
        update.save!

        if update.email
          body = markdown(update.body) 
          body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

          students.map do |s|
            Mailer.klass_update(
              current_account.slug, 
              current_account.config['mailer']['noreply'], 
              s.user_email, 
              update.subject, 
              body, klass.id
            ).deliver_later
          end
        end
        # elsif generator.unit_id
          
        # end
      end
    end
  end
end