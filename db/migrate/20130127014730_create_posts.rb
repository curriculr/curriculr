class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to  :forum, index: true
      t.belongs_to  :topic, index: true
      t.belongs_to :author, :polymorphic => true, index: true
      t.belongs_to  :parent
      t.text     :about
      t.integer  :ups, :default => 0
      t.integer  :downs, :default => 0
      t.integer  :posts_count, :default => 0
      t.boolean  :anonymous, :default => false

      t.timestamps null: false
    end

    add_foreign_key :posts, :forums
    add_foreign_key :posts, :topics
  end
end
