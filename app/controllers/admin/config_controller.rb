module Admin
  class ConfigController < BaseController
    include WithSettings
    before_action :require_admin
    
    def edit
      @settings = JSON.pretty_generate($site)
      render 'admin/config/show'
    end

    def update
      do_configure($site, "config.site", admin_config_edit_path)
    end
  end
end