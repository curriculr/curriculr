class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
	def to_s
	  if resource
      "#{I18n.t("config.staff.#{name}")}(#{resource.name})"
    else
      I18n.t("config.role.#{name}")
    end
  end
end
