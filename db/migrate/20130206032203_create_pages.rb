class CreatePages< ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.belongs_to :account, index: true
      t.belongs_to :owner, :polymorphic => true, :index => true
      t.string :name
      t.text :about
      t.string :section
      t.string :slug
      t.boolean :blog, :default => false
      t.boolean :html, :default => false
      t.boolean :public, :default => false
      t.boolean :published, :default => false
      t.integer :order, :default => 0

      t.timestamps null: false
    end

    add_foreign_key :pages, :accounts
  end
end
