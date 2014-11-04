module Learn
  class KlassesController < BaseController
    responders :flash, :http_cache

    def index
      @q = Klass.which_are(params[:s], current_user).search(params[:q])
    
      unless @q.present?
        params[:s] = nil
        @q = Klass.available(current_user).search(params[:q])
      end
      
      @klasses = @q.result.page(params[:page]).per(10)

      respond_with @klasses do |format|
        format.html { render :index }
      end
    end

    def show
      if @klass.enrolled?(current_student) #and @enrollment.last_attended_at.blank?
        @enrollment.update(last_attended_at: Time.zone.now)
        if (survey = @klass.course.assessments.tagged_with(:on_enroll, :on => :events).first) and survey.can_be_taken?(@klass, current_student)
          redirect_to new_learn_klass_assessment_attempt_path(@klass, survey)
        end
      end
    end

    def students
      @q = @klass.enrollments.search(params[:q])
      @enrollments = @q.result.page(params[:page]).per(10)
    end
    
    def enroll
      if current_user
        if params[:agreed]
          if KlassEnrollment.enroll(@klass, current_student)
            KlassEnrollment.send_email(current_user.email, [@klass], url_for(:controller => 'devise/sessions', :action => 'new')) 
            redirect_to learn_klass_path(@klass), :flash => {:notice => t('activerecord.messages.successful_enroll')}
          else
            redirect_to learn_klass_path(@klass), :flash => {:error => t('activerecord.messages.failure_to_enroll')} 
          end
        else
          @klasses = [@klass]
          @url = main_app.enroll_learn_klass_path(@klass)
          @page_header = t('page.titles.klass_agreement');
          flash.now[:alert] = t('activerecord.messages.must_agree_to_terms') if params[:klasses]
          render 'agreement'
        end
      end
    end
  
    def drop
      if current_user
        if KlassEnrollment.drop(@enrollment)
          if (survey = @klass.course.assessments.tagged_with(:on_drop, :on => :events).first) and survey.can_be_taken?(@klass, current_student)
            redirect_to new_learn_klass_assessment_attempt_path(@klass, survey), :flash => {:notice => t('activerecord.messages.successful_drop')} 
          else
            redirect_to learn_klass_path(@klass), :flash => {:notice => t('activerecord.messages.successful_drop')} 
          end
        else
          redirect_to learn_klass_path(@klass), :flash => {:error => t('activerecord.messages.failure_to_drop')} 
        end
      end
    end
  
    def report
    end
    
    def decline
      if current_user && @klass.private && (@enrollment = @klass.enrollments.where(:student_id => @student.id).first)
        if !@enrollment.active && @enrollment.accepted_or_declined_at.blank?
          if KlassEnrollment.decline(@enrollment)
            redirect_to learn_klasses_path 
          else
            redirect_to learn_klass_path(@klass), :flash => {:error => t('activerecord.messages.unable_to_decline')} 
          end
        end
      end
    end
  
    def search
      criteria = []
      criteria << "courses.locale in ('#{params[:locale].keys.join("','")}')" if params[:locale]
      criteria << "courses.country in ('#{params[:country].keys.join("','")}')" if params[:country]
    
      @klasses = Klass.which_are(params[:s], current_user).where(criteria.join(' and ')).joins(:course)

      if params[:level]
        @klasses = @klasses.joins("left outer join taggings l on courses.id = l.taggable_id and l.taggable_type = 'Course' and l.context = 'levels'").
        joins("left outer join tags lt on l.tag_id = lt.id").where("lt.name in (:levels)", levels: params[:level].keys)
      end
      
      if params[:major]
        @klasses = @klasses.joins("left outer join taggings m on courses.id = m.taggable_id and m.taggable_type = 'Course' and m.context = 'majors'").
        joins("left outer join tags mt on m.tag_id = mt.id").where("mt.name in (:majors)", majors: params[:major].keys)
      end
      
      if params[:subject]
        @klasses = @klasses.joins("left outer join taggings s on courses.id = s.taggable_id and s.taggable_type = 'Course' and s.context = 'subjects'").
        joins("left outer join tags st on s.tag_id = st.id").where("st.name in (:subjects)", subjects: params[:subject].keys)
      end
      
      @klasses
    end
  end
end
