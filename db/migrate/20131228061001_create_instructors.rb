class CreateInstructors < ActiveRecord::Migration
  def change
    create_table :instructors do |t|
      t.belongs_to :user, index: true
      t.belongs_to :course, index: true
      t.integer :order, :default => 0
      t.string :name
      t.string :title
      t.string :role
      t.text :about
      t.string :avatar
      t.boolean :active, :default => true

      t.timestamps null: false
    end

    add_foreign_key :instructors, :users
    add_foreign_key :instructors, :courses
  end
end
