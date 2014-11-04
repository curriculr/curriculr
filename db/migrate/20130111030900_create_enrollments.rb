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

      t.timestamps
    end
  end
end


#update enrollments set last_attended_at = last_attendance_at;
#update enrollments set active = FALSE, dropped_at = updated_at where dropped = TRUE;
#update enrollments set active = TRUE  where dropped = FALSE;
