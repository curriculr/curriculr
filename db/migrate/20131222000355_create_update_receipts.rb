class CreateUpdateReceipts < ActiveRecord::Migration
  def change
    create_table :update_receipts do |t|
      t.belongs_to :update, index: true
      t.string :kind
      t.integer :success
      t.integer :failure
      t.integer :total
      t.datetime :at
    end
  end
end
