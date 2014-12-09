module Learn
	class DashboardController < BaseController
		skip_load_and_authorize_resource

		def show
			unless current_user && staff?(current_user, @klass)
				raise CanCan::AccessDenied.new("Not authorized!", :show, :dashboard)
			end
  	end
	end
end