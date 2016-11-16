module Authorizable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :roles, :join_table => :users_roles
    
    def has_role?(role_name, resource = nil)
      @roles ||= self.roles.all
      
      @roles.any?{|r| r.name == role_name.to_s && (resource.nil? || resource == r.resource)}
    end
    
    
    def add_role(role_name, resource = nil)
      self.transaction do
        self.roles << Role.find_or_create_by(name: role_name.to_s, resource: resource)
      end
    end
        
    def remove_role(role_name, resource = nil)
      roles = self.roles.where(name: role_name.to_s, resource: resource)
      self.transaction do
        roles.each do |role|
          self.roles.delete(role)
        
          unless role.users.any?
            role.destroy
          end
        end
      end
    end
  end

  module ClassMethods
    def with_role(role_name)
      User.joins(:roles).where("roles.name = :role", role: role_name)
    end
	end
end
