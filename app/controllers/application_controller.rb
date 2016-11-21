require "application_responder"
require "#{Rails.root}/app/responders/modal_responder"

class KlassAccessDeniedError < StandardError; end

class ApplicationController < PreApplicationController
  protect_from_forgery with: :exception

  helper EditorsHelper, MenuHelper, CoursesHelper, KlassesHelper, 
    DashboardHelper, SettingsTreeHelper, UiComponentsHelper, FormsHelper

  Rails.application.config.site_engines.each do |name, config|
    helper config[:helper] if config[:helper].present?
  end

  helper_method :require_admin, :mounted?, :staff?,
    :check_access?, :check_access!, :current_account,
    :current_user, :user_signed_in?, :current_student

  config.filter_parameters :password, :password_confirmation

  def routing_error
		raise ActionController::RoutingError.new(params[:path])
	end
  
  include Themed
  include Authenticated
  include Authorized
end
