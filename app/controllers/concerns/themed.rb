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
      @current_theme = current_account.config['theme'] || $site['default_theme']
      if @current_theme && $site['available_themes'][@current_theme]
        theme_and_parents($site['available_themes'], themes, @current_theme)
      else
        @current_theme = "sunshine"
        themes << "sunshine"
      end

      themes.reverse.each do |theme|
        begin
          if $site['available_themes'][theme]['helper?']
            self.class.send :helper, "themes/#{theme}/#{theme}"
          end
        rescue AbstractController::Helpers::MissingHelperError => error
        end

        prepend_view_path "app/views/themes/#{theme}"
        prepend_view_path "app/views_overrides/#{locale}"
      end
    end
    
    def current_theme
      @current_theme
    end
  end

  module ClassMethods
	end
end