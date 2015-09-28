class PreApplicationController < ActionController::Base
  include ScopedByAccount
  include WithMountableEngines

  before_action :set_timezone
  before_action :load_request_data
  before_action :set_page_header
  before_action :set_app_menus

  #after_action :store_location
  helper_method :add_item_to_app_menu, :app_menu

  layout :set_layout

  private

  def set_layout
    request.xhr? ? false : 'application'
  end

  def store_location
    if (request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_up" &&
        request.fullpath != "/users/password" &&
        request.fullpath != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def set_timezone
    Time.zone = current_user.time_zone if current_user
  end

  def set_page_header
    if @course
      @page_header = @course.name
    elsif @klass
      @page_header = @klass.course.name
    end
  end

  def load_req_object(model, controller, named_id)
    model = model.respond_to?(:scopeable?) ? model.scoped : model
    if params[named_id]
      data = model.find(params[named_id]) if params[named_id].present?
    elsif params[:id] and params[:controller] == controller
      data = model.find(params[:id])
    end

    @req_objects << data if @req_objects and data
    data
  end

  def load_request_data
    if self.class.name.starts_with?('Learn::')
      @req_objects = [:learn]
    elsif self.class.name.starts_with?('Teach::')
      @req_objects = [:teach]
    elsif self.class.name.starts_with?('Admin::')
      @req_objects = [:admin]
    else
      @req_objects = []
    end

    @req_attributes = {}

    I18n.locale = (current_account.config['locale'] || I18n.default_locale)
  end

  def set_app_menus
    @app_menus = {
      :site_top     => {:_ => [], :right => []},
      :site_bottom  => {},
      :course_side  => {:_ => []},
      :klass_side   => {:_ => []},
      :home_page    => {:_ => []}
    }
  end

  def add_item_to_app_menu(menu, item, section = :_)
    unless @app_menus[menu][section]
      @app_menus[menu][section] = []
    end

    @app_menus[menu][section] << item if menu && section && item
  end

  def app_menu(menu)
    @app_menus[menu]
  end
end
