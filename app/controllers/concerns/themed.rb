module Themed
  extend ActiveSupport::Concern

  included do
    before_action :set_theme
    
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
        @current_theme = { "name"=>"sunshine" }
        themes << "sunshine"
      end

      themes.reverse.each do |theme|
        begin
          self.class.send :helper, "themes/#{theme}/#{theme}"
        rescue
        end

        prepend_view_path "app/views/themes/#{theme}"
        prepend_view_path "app/views_overrides/#{locale}"
      end
    end
  end

  module ClassMethods
	end
end