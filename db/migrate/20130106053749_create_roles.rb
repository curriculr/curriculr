class CreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:users_roles, [ :user_id, :role_id ])
  end
  
=begin  
  def change
    create_table :roles do |t|
      t.belongs_to :user
      t.string :role 
      t.string :title
      t.references :for, :polymorphic => true
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0
      
      t.timestamps
    end
  end
=end  
end

