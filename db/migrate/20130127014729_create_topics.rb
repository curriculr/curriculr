class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.belongs_to  :forum, index: true
      t.belongs_to :author, :polymorphic => true, index: true
      t.string :name
      t.text :about
      t.integer :hits, :default => 0
      t.integer :posts_count, :default => 0
      t.integer :ups, :default => 0
      t.integer :downs, :default => 0
      t.integer :points_per_post, :default => 0
      t.integer :points_per_reply, :default => 0
      t.boolean :active, :default => true
      t.boolean :sticky, :default => false
      t.boolean :locked, :default => false
      t.boolean :anonymous, :default => false

      t.timestamps null: false
    end

    add_foreign_key :topics, :forums
  end
end
