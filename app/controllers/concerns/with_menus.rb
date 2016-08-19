module WithMenus
  extend ActiveSupport::Concern

  included do
    before_action :set_app_menus
    helper_method :add_to_app_menu, :app_menu, :app_menus
    
    def set_app_menus
      @app_menus = {
        :top     => {_: [], right: []},
        :bottom  => {_: []},
        :course  => {_: []},
        :klass   => {_: []},
        :user    => {_: []}
      }
    end

    def add_to_app_menu(menu, item, section = :_)
      @app_menus[menu][section] ||= []
      
      case item
      when Array
        @app_menus[menu][section].concat(item)
      else
        @app_menus[menu][section] << item
      end
    end

    def app_menu(menu, section = :_)
      @app_menus[menu][section]
    end
    
    def app_menus(menu)
      @app_menus[menu]
    end
  end

  module ClassMethods
	end
end