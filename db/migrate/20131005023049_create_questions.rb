class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.belongs_to :course, index: true
      t.belongs_to :unit, index: true
      t.belongs_to :lecture, index: true
      t.string :kind
      t.text :question
      t.text :hint
      t.text :explanation
      t.integer :options_count, :default => 0
      t.integer :order, :default => 0
      t.boolean :include_in_lecture, :default => false

      t.timestamps null: false
    end

    add_foreign_key :questions, :courses
    add_foreign_key :questions, :units
    add_foreign_key :questions, :lectures
  end
end
