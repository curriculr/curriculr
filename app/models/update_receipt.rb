class UpdateReceipt < ActiveRecord::Base
  belongs_to :update1, :class_name => 'Update'
end
	