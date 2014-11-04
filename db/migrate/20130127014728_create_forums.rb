class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.belongs_to :klass, index: true
      t.string :name
      t.text :about
      t.boolean :active, :default => true
      t.boolean :sticky, :default => false
      t.boolean :lecture_comments, :default => false
      t.boolean :graded, :default => false
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0

      t.timestamps
    end
  end
end