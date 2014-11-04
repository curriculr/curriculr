class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.belongs_to :owner, :polymorphic => true, index: true
      t.belongs_to :medium, :index => true
      t.string :kind
      
      t.timestamps
    end
  end
end
