class CreateFacultyApplications < ActiveRecord::Migration
  def change
    create_table :faculty_applications do |t|
      t.belongs_to :user, :null => false, index: true
      t.string :name, :null => false
      t.text :about, :null => false
      t.string :prefix
      t.boolean :update_profile, :default => false
      t.string :course, :null => false
      t.text :description, :null => false
      t.integer :weeks
      t.integer :workload
      t.string :locale
      t.string :country
      t.boolean :approved, :default => false
      t.datetime :declined_at

      t.timestamps null: false
    end

    add_foreign_key :faculty_applications, :users
  end
end
