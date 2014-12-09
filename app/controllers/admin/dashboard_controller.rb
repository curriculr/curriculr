module Admin
	class DashboardController < BaseController
		skip_load_and_authorize_resource

  	def show
  		unless current_user && current_user.has_role?(:admin)
				raise CanCan::AccessDenied.new("Not authorized!", :show, :dashboard)
			end
  	end
	end
end
