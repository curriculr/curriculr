# This migration comes from payment (originally 20150507003504)
class AddPaymentCustomerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payment_customer_id, :string
  end
end
