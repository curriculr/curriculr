class PreApplicationController < ActionController::Base
  include WithMenus
  include EngineMounted
  include Localized
  
  before_action :set_timezone
  before_action :load_request_data
  before_action :set_locale
  before_action :set_page_header

  layout :set_layout

  private

  def set_layout
    request.xhr? ? false : 'application'
  end

  def set_page_header
    if @course
      @page_header = @course.name
    elsif @klass
      @page_header = @klass.course.name
    end
  end

  def load_req_object(model, controller, named_id)
    data = nil
    model = model.respond_to?(:scopeable?) ? model.scoped : model
    if params[named_id]
      data = model.find(params[named_id]) if params[named_id].present?
    elsif params[:id] && params[:controller] == controller
      data = model.find(params[:id])
    end

    @req_objects << data if @req_objects && data
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
  end
  
  def current_account
    request.env['curriculr.current_account']
  end
end
