# This migration comes from payment (originally 20150123152958)
class AddPaymentToKlasses < ActiveRecord::Migration
  def change
    add_reference :klasses, :payment_plan, index: true
    add_column :klasses, :payment_for_mask, :integer, default: 1
  end
end
