module Teach
  class KlassesController < BaseController
    responders :modal, :flash, :http_cache

    def show
      render :action => :index
    end

    def new
      @klass = Klass.new
    end

    def create
      @klass = @course.klasses.new(klass_params)
      @klass.save
      respond_with @klass
    end
    
    def edit
      @klass.slug = @klass.slug.split(':')[1]
    end

    def index
    end

    def update
      @klass = Klass.scoped.find(params[:id])
      @klass.update(klass_params)
      respond_with @klass
    end

    def destroy
      @klass.destroy

      respond_with @klass do |format|
        format.html { redirect_to teach_course_path(@course) }
      end
    end

    def approve
      if current_user.has_role? :admin || (staff?(current_user, @course) && !current_account.config['require_admin_approval_of_classes'])
        @klass.approved = !@klass.approved
        @klass.approved_at = Time.zone.now
        @klass.save

        respond_with @klass do |format|
          format.html { redirect_to teach_course_klasses_path(@course) }
        end
      end
    end

    def ready
      if current_user && staff?(current_user, @course)
        if @klass.ready_to_approve
          @klass.ready_to_approve = false
          @klass.approved = false
        else
          @klass.ready_to_approve = true
        end

        @klass.save

        respond_with @klass do |format|
          format.html { redirect_to teach_course_klasses_path(@course) }
        end
      end
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
          invitable &&= (@klass.private && current_user.email != params[:invitation][:invitee] && staff?(current_user, @course))

          if invitable
            user = User.scoped.find_by(:email => params[:invitation][:invitee])

            invitable &&= user && (enrollment = KlassEnrollment.enroll(@klass, user.self_student, true))

            invitable &&=  !enrollment.active && enrollment.dropped_at.blank? && enrollment.accepted_or_declined_at.blank?
          end
        end

        if invitable
          url = url_for :controller => 'auth/sessions', :action => 'new'
          Mailer.klass_invitation(
            current_account.slug,
            current_account.config['mailer']['noreply'],
            @invitation.invitee,
            @klass.id,
            current_user.name || current_user.email,
            url
          ).deliver_later

          redirect_to students_learn_klass_path(@klass), :notice => t('helpers.notice.invitation_sent')
        else
          flash.now[:alert] = t('helpers.notice.unable_to_invite')
          render 'invite'
        end
      end
    end

    private
      def klass_params
        params.require(:klass).permit(:about, :featured, :begins_on,
          :ends_on, :private, :previewed, :allow_enrollment, :slug,
          :lectures_on_closed)
      end
  end
end
