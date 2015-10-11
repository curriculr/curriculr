class CreateKlasses < ActiveRecord::Migration
  def change
    create_table :klasses do |t|
      t.belongs_to :account, index: true
    	t.belongs_to :course, index: true
      t.string :slug, index: true
      t.text :about
    	t.boolean :active, :default => true
      t.boolean :ready_to_approve, :default => false
    	t.boolean :featured, :default => false
      t.boolean :approved, :default => false
      t.boolean :previewed, :default => false
      t.boolean :private, :default => false
      t.boolean :lectures_on_closed, :default => true
      t.boolean :allow_enrollment, :default => true
      t.date :begins_on, :null => false
      t.date :ends_on
      t.integer :enrollments_count, :default => 0
      t.integer :active_enrollments, :default => 0
      t.datetime :approved_at

      t.timestamps null: false
    end

    add_foreign_key :klasses, :accounts
    add_foreign_key :klasses, :courses
  end
end
