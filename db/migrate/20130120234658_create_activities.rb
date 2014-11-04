class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :klass, index: true
      t.belongs_to :student, index: true
      t.references :actionable, :polymorphic => true
      t.string :action
      t.integer :times, :default => 0
      t.integer :points, :default => 0
    end
  end
end
