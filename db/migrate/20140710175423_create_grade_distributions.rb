class CreateGradeDistributions < ActiveRecord::Migration[5.0]
  def change
    create_table :grade_distributions do |t|
      t.belongs_to :course, index: true
      t.string :level
      t.string :kind
      t.float :grade

      t.timestamps null: false
    end

    add_foreign_key :grade_distributions, :courses
  end
end
