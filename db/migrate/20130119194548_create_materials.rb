class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.belongs_to :owner, :polymorphic => true, index: true
      t.belongs_to :medium, :index => true
      t.string :kind
      t.integer :order, :default => 0

      t.timestamps null: false
    end

    add_foreign_key :materials, :media
  end
end
