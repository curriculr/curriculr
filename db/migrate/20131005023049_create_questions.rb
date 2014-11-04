class CreateQuestions < ActiveRecord::Migration
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

      t.timestamps
    end
  end
end
