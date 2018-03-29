class CreateAttempts < ActiveRecord::Migration[5.0]
  def change
    create_table :attempts do |t|
      t.belongs_to :klass, index: true
      t.belongs_to :enrollment, index: true
      t.belongs_to :student, index: true
      t.belongs_to :assessment, index: true
      t.integer :state
      t.text :test
      t.integer :points
      t.float :score

      t.timestamps null: false
    end

    add_foreign_key :attempts, :klasses
    add_foreign_key :attempts, :enrollments
    add_foreign_key :attempts, :students
    add_foreign_key :attempts, :assessments
  end
end
