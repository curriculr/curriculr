class CreateAttempts < ActiveRecord::Migration
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

      t.timestamps
    end
  end
end
