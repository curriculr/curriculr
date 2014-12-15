module Teach
  class UpdatesController < BaseController
    responders :flash, :http_cache
  
    def make
      @update = Update.find(params[:id])
      if !@update.made and !@update.cancelled
        @update.made = true
        @update.save!

        if @update.email
          body = view_context.markdown(@update.body) 
          students = @update.klass.students.joins(:user).where('enrollments.active = TRUE').
            select('users.name as user_name, users.email as user_email, students.name as student_name')
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
      @update = Update.new(update_params)

      respond_with @update do |format|
        if @update.save
          format.html { redirect_to teach_course_klass_path(@course, @klass, :show => 'updates') }
        else
          format.html { render action: "new" }
        end
      end
    end

    def update
      @update = Update.find(params[:id])

      respond_with @update do |format|
        if @update.update(update_params)
          format.html { redirect_to teach_course_klass_path(@course, @klass, :show => 'updates') }
        else
          format.html { render action: "edit" }
        end
      end
    end

    def destroy
      @update = Update.find(params[:id])
      @update.destroy

      respond_with @update do |format|
        format.html { redirect_to teach_course_klass_path(@course, @klass, :show => 'updates') }
      end
    end

    private
    def update_params
      params.require(:update).permit(:course_id, :unit_id, :lecture_id, :klass_id, :www, 
        :email, :sms, :twitter, :facebook, :event, :frequency, :to, :subject, :body)
    end
  end
end