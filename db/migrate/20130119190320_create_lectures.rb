class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.belongs_to :unit, index: true
      t.integer :order, :default => 0
      t.string :name
      t.text :about
      t.integer :points, :default => 0
      t.integer :assessments_count, :default => 0
      t.integer :pages_count, :default => 0
      t.date :on_date
      t.date :based_on
      t.integer :for_days
			t.boolean :allow_discussion, :default => true
      t.boolean :previewed, :default => false
			
      t.timestamps
    end
  end
end
