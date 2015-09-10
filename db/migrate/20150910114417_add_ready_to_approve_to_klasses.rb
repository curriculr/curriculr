class AddReadyToApproveToKlasses < ActiveRecord::Migration
  def change
    add_column :klasses, :ready_to_approve, :boolean, default: false
  end
end
