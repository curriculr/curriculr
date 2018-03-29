class CreateQSelectors < ActiveRecord::Migration[5.0]
  def change
    create_table :q_selectors do |t|
      t.belongs_to :assessment, index: true
      t.string :set
      t.integer :points, :default => 0
      t.integer :order, :default => 0
      t.references :question, index: true
      t.string :kind
      t.integer :questions_count, :default => 1
      t.references :lecture, index: true
      t.references :unit, index: true
      t.text :tags

      t.timestamps null: false
    end

    add_foreign_key :q_selectors, :assessments
  end
end
