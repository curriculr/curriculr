class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.belongs_to :account, index: true
      t.string :slug, null: false, index: true
      t.string :name
      t.text :about
      t.boolean :active, :default => true
      t.integer :weeks
      t.integer :workload
      t.integer :klasses_count, :default => 0
      t.integer :units_count, :default => 0
      t.integer :assessments_count, :default => 0
      t.integer :pages_count, :default => 0
      t.integer :media_count, :default => 0
      t.belongs_to :originator, :polymorphic => true
      t.string :locale
      t.string :country

      t.timestamps
    end
  end
end
