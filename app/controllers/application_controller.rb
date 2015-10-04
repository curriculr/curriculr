class KlassAccessDeniedError < StandardError; end

class ApplicationController < PreApplicationController
  protect_from_forgery with: :exception

  helper EditorsHelper, UiHelper, CoursesHelper, KlassesHelper, DashboardHelper

  Rails.application.config.site_engines.each do |name, config|
    helper config[:helper] if config[:helper].present?
  end

  helper_method :require_admin, :mounted?, :staff?,
    :check_access?, :check_access!, :current_student

  config.filter_parameters :password, :password_confirmation

  before_action :set_theme
  before_action :configure_devise_params, if: :devise_controller?

	rescue_from CanCan::AccessDenied, :with => :render_401
  rescue_from KlassAccessDeniedError do |e|
    flash[:part] = e.message
    redirect_to access_learn_klass_path(@klass)
  end

  def routing_error
		raise ActionController::RoutingError.new(params[:path])
	end

  private

  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation)
    end
  end

  def theme_and_parents(config, themes, theme)
    if config[theme] && config[theme]['parent']
      themes << theme.strip
      theme_and_parents(config, themes, config[theme]['parent'])
    else
      themes << theme.strip
    end
  end


  def set_theme
    themes = []
    @current_theme = current_account.config['theme'] || $site['theme']
    if @current_theme && @current_theme['name'] && $site['available_themes'][@current_theme['name']]
      theme_and_parents($site['available_themes'], themes, @current_theme['name'])
    else
      @current_theme = { "name"=>"bootstrap", "fluid"=>false, "flavor"=>"vanilla" }
      themes << "bootstrap"
    end

    themes.reverse.each do |theme|
      begin
        self.class.send :helper, "themes/#{theme}/#{theme}"
      rescue
      end

      prepend_view_path "app/views/themes/#{theme}"
    end
  end

  def staff?(user, course)
    KlassEnrollment.staff?(user, course)
  end

	def render_401 (exception = nil)
		if exception
      if current_user
        redirect_to error_401_path
      else
        store_location_for(:user, request.fullpath)
        redirect_to main_app.new_user_session_path, :flash => {:notice => t('activerecord.messages.must_signin', :path => request.path) }
      end
		end
	end

  def current_student
    if user_signed_in?
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
