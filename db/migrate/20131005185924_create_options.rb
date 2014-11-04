class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.belongs_to :question, index: true
      t.text :option
      t.string :answer
      t.text :answer_options
      t.integer :order, :default => 0

      t.timestamps
    end
  end
end
