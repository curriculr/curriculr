module Authorized
  extend ActiveSupport::Concern

  included do
  	rescue_from CanCan::AccessDenied, :with => :render_401
    rescue_from KlassAccessDeniedError do |e|
      flash[:part] = e.message
      redirect_to access_learn_klass_path(@klass)
    end
    
    def staff?(user, course)
      KlassEnrollment.staff?(user, course)
    end

  	def render_401 (exception = nil)
  		if exception
        if current_user
          redirect_to error_401_path
        else
          ###store_location_for(:user, request.fullpath) if request.get?
          redirect_to main_app.auth_signin_path, :flash => {:notice => t('activerecord.messages.must_signin', :path => request.path) }
        end
  		end
  	end
  
    def current_student
      @current_student ||= if user_signed_in?
        if session[:current_student].present?
          Student.find(session[:current_student])
        else
          Student.where(:user_id => current_user.id, :relationship => 'self').first
        end
      else
        nil
      end
    end

    def check_access! (part)
      if !check_access?(part)
        raise KlassAccessDeniedError, part
      end
    end

    def check_access? (part)
      if @klass.respond_to?(:with_access?)
        @klass.with_access?(part, current_student, @enrollment)
      else
        true
      end
    end

    def require_admin
      unless current_user && current_user.has_role?(:admin)
        redirect_to home_path, :flash => {:notice => t('activerecord.messages.must_be_admin')}
        return false
      end
    end
  end

  module ClassMethods
	end
end