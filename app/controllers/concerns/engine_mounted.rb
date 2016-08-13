module EngineMounted
  extend ActiveSupport::Concern

  included do
    helper_method :mounted?, :mountable_fragments

    def mounted?(engine)
      Rails.application.config.site_engines[engine.to_sym].present?
    end

    def mountable_fragments(hook, options={})
      if (ndx = (hook_str = hook.to_s).rindex(/\_/))
        html = ''
        fragment = hook_str[(ndx + 1)..hook_str.length].to_sym
        options[fragment] = hook_str[0..(ndx - 1)].to_sym
        Rails.application.config.site_engines.each do |name, engine|
          if engine[:fragments] && engine[:fragments][fragment]
            html << render_to_string(partial: "#{name}/fragments/#{fragment}", locals: options)
          end
        end

        html.html_safe
      end
    end
    
    # To allow extending menus from mountable engines
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

  module ClassMethods
  end
end
