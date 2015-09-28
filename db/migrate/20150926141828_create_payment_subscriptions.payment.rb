# This migration comes from payment (originally 20150124133355)
class CreatePaymentSubscriptions < ActiveRecord::Migration
  def change
    create_table :payment_subscriptions do |t|
      t.belongs_to :payment_plan, index: true
      t.belongs_to :subscriber, polymorphic: true
      t.belongs_to :participant, polymorphic: true
      t.string :gateway, :null => false
      t.string :payer_id, :null => false
      t.string :payment_id, :null => false
      t.float :amount, :null => false
      t.boolean :active, default: true
      t.integer :number_of_billing_cycles
      t.date :first_billing_date, :null => false
      t.date :next_billing_date
      t.datetime :paid_at
      t.datetime :suspended_at
      t.datetime :expired_at
      t.datetime :cancelled_at
      t.text :data

      t.timestamps null: false
    end

    add_foreign_key :payment_subscriptions, :payment_plans
  end
end
