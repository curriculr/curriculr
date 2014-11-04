require 'rufus-scheduler'

class Notifier
    def self.make(current_account, update)
    if update.email && !update.cancelled && (!update.made || (update.made && update.made_at.blank?))
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => false)
      notifyees = audience(update.klass, (update.to == 'students' || update.to == 'all'))
      subject = update.subject
      body = markdown.render(update.body) 
      klass = update.klass
      account = current_account
      from = current_account.config['mailer']['noreply']

      scheduler = Rufus::Scheduler.new
      scheduler.in '5s' do
        Account.current_id = account.id

        receipt = UpdateReceipt.new(:update_id => update.id, :kind => 'email', :total => notifyees.count)
        failure_count = 0
        notifyees.each do |n|
          begin
            Mailer.klass_update(account, from, n[:email], subject, body, klass).deliver
          rescue
            failure_count += 1
          end
        end
        
        update.transaction do
          receipt.failure = failure_count
          receipt.success = receipt.total - receipt.failure
          receipt.at = Time.zone.now
          receipt.save!
          
          update.made = true
          update.made_at = Time.zone.now
          update.save!
        end
      end
    end
  end
  
  def self.audience(klass, include_students = true)
    audience = []
    if include_students
      students = klass.students.joins(:user).where('enrollments.active = TRUE').select('users.name as user_name, users.email as user_email, students.name as student_name')
      audience = students.map do |s|
        {
          user: s.user_name,
          student: s.student_name,
          email: s.user_email
        }
      end
    end
    
    audience
  end
end