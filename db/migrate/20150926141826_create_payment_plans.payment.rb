# This migration comes from payment (originally 20150123150814)
class CreatePaymentPlans < ActiveRecord::Migration
  def change
    create_table :payment_plans do |t|
      t.belongs_to :account, index: true, :null => false
      t.string :name, :null => false
      t.text :about, :null => false
      t.string :amount, :null => false
      t.string :plan_id, :null => false
      t.integer :number_of_billing_cycles
      t.integer :trial_days, :default => 0
      t.boolean :active, :default => true
      t.datetime :cancelled_at

      t.timestamps null: false
    end

    add_foreign_key :payment_plans, :accounts
  end
end
