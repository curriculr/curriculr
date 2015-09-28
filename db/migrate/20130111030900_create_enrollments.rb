class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
    	t.belongs_to :klass, index: true
			t.belongs_to :student, index: true
      t.float :final_score, :default => 0.0
      t.string :letter_grade
      t.boolean :active, :default => false
      t.datetime :dropped_at
      t.datetime :suspended_at
      t.datetime :invited_at
      t.datetime :accepted_or_declined_at
      t.datetime :last_attended_at
      t.text :data

      t.timestamps null: false
    end

    add_foreign_key :enrollments, :klasses
    add_foreign_key :enrollments, :students
  end
end
