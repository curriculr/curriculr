module Teach
  class UpdatesController < BaseController
    responders :flash, :http_cache
    helper_method :the_path_out
  
    def make
      @update = Update.find(params[:id])
      if @update.active && @update.sent_at.blank?
        if @update.email
          body = view_context.markdown(@update.body) 
          students = @update.klass.students.joins(:user).where('enrollments.active = TRUE').
            select('users.name as user_name, users.email as user_email, students.name as student_name')

          instructors = @update.klass.instructors
          body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

          students.map do |s|
            Mailer.klass_update(
              current_account.slug, 
              current_account.config['mailer']['noreply'], 
              s.user_email, 
              @update.subject, 
              body, @update.klass.id
            ).deliver_later
          end
        end

        @update.sent_at = Time.zone.now
        @update.save
      end
      
      respond_with @update do |format|
        format.html { redirect_to teach_course_klass_path(@course, @klass, :show => 'updates') }
      end
    end
  
    def index
      criteria = [ "klass_id is null", "course_id = #{@course.id}" ]
    
      if @unit
        criteria << "unit_id = #{@unit.id}"
      else
        criteria << "unit_id is null"
      end
    
      if @lecture
        criteria << "lecture_id = #{@lecture.id}" if @lecture
      else
        criteria << "lecture_id is null"
      end

      if params[:s] and params[:s] != 'all' 
        criteria << "kind like '#{params[:s]}%' "
      end
     
      @updates = Update.where(criteria.join(' and '))
    end

    def show
      @update = Update.find(params[:id])
    end

    def new
      @update = Update.new(:course => @course, 
        :unit => @unit,
        :lecture => @lecture, :klass => @klass)
    end

    def edit
      @update = Update.find(params[:id])
    end

    def create
      @update = if @klass
        @klass.updates.new(update_params)
      elsif @lecture
        @lecture.updates.new(update_params)
      elsif @unit
        @unit.updates.new(update_params)
      else
        @course.updates.new(update_params)
      end

      respond_with @update do |format|
        if @update.save
          format.html { redirect_to the_path_out }
        else
          format.html { render action: "new" }
        end
      end
    end

    def update
      @update = Update.find(params[:id])

      respond_with @update do |format|
        if @update.update(update_params)
          format.html { redirect_to the_path_out }
        else
          format.html { render action: "edit" }
        end
      end
    end

    def destroy
      @update = Update.find(params[:id])
      @update.destroy

      respond_with @update do |format|
        format.html { redirect_to the_path_out }
      end
    end

    private
    def update_params
      params.require(:update).permit(:www, :email, :active, :to, :subject, :body)
    end

    def the_path_out
      if @klass
        teach_course_klass_path(@course, @klass, :show => 'updates')
      else
        url_for([:teach, @course || @update.course, @unit || @update.unit, @lecture || @update.lecture, @klass, show: 'updates'])

        # if @lecture 
        #   teach_course_unit_lecture_path(@course, @lecture.unit, @lecture, show: 'updates')
        # elsif @unit
        #   teach_course_unit_path(@course, @unit, show: 'updates')
        # elsif @course
        #   teach_course_path(@course, show: 'updates')
        # end
      end
    end
  end
end