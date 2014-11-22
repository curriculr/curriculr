module Teach
  class KlassesController < BaseController
    responders :flash, :http_cache
  
    def show      
      render :action => :index
    end
    
    def edit
      @klass.slug = @klass.slug.split(':')[1]
    end

    def index
    end
    
    def update
      @klass = Klass.find(params[:id])

      respond_with @klass do |format|
        if @klass.update(klass_params)
          format.html { redirect_to teach_course_klasses_path(@course) }
        else
          #@klass.slug = @klass.slug.split(':')[1]
          format.html { render action: "edit" }
        end
      end
    end

    def destroy
      @klass.destroy

      respond_with @klass do |format|
        format.html { redirect_to teach_course_path(@course) }
      end
    end

    def new
      @klass = Klass.new
    end

    def create
      @klass = @course.klasses.new(klass_params)
      respond_with @klass do |format|
        if @klass.save
          format.html { redirect_to teach_course_klasses_path(@course) }
        else
          format.html { render action: "new" }
        end
      end
    end
    
    def approve
      if current_user.has_role? :admin or (staff?(current_user, @course) and !current_account.config['require_admin_approval_of_classes'])
        @klass.approved = !@klass.approved 
        @klass.approved_at = Time.zone.now
        @klass.save 
        
        respond_with @klass do |format|
          format.html { redirect_to teach_course_klasses_path(@course) }
        end
      end
    end

    def reports
    end
    
    def invite
      if request.get?
        @invitation = Invitation.new
        render 'invite'
      else
        @invitation = Invitation.new
        @invitation.invitee = params[:invitation][:invitee]

        invitable = true 
        invitable &&= @invitation.valid?
        if invitable
          invitable &&= @klass.private and current_user.email != params[:invitation][:invitee] and staff?(current_user, @course)
          
          if invitable
            user = User.find_by(:email => params[:invitation][:invitee])

            invitable &&= user && (enrollment = KlassEnrollment.enroll(@klass, user.self_student, true))

            invitable &&=  !enrollment.active && enrollment.dropped_at.blank? && enrollment.accepted_or_declined_at.blank?
          end
        end

        if invitable
          url = url_for :controller => 'devise/sessions', :action => 'new'  
          Mailer.klass_invitation(current_account, current_user.name || current_user.email, @klass, params[:invitation][:invitee], url).deliver
          redirect_to students_learn_klass_path(@klass), :notice => t('activerecord.messages.invitation_sent')
        else
          flash.now[:alert] = t('activerecord.messages.unable_to_invite')
          render 'invite'
        end
      end
    end
    
    private 
      def klass_params
        params.require(:klass).permit(:about, :featured, :begins_on, 
          :ends_on, :private, :previewed, :allow_enrollment, :slug,
          :lectures_on_closed, :free, :tuition_plan, :membership => [], :required_for => [])
      end
  end
end