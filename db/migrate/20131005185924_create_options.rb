class CreateOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :options do |t|
      t.belongs_to :question, index: true
      t.text :option
      t.string :answer
      t.text :answer_options
      t.integer :order, :default => 0

      t.timestamps null: false
    end

    add_foreign_key :options, :questions
  end
end
