require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def setup
		@account = accounts(:primary)
	end

	test "with valid fixtures" do
    assert accounts(:primary).valid?
    assert accounts(:secondary).valid?
  end

  test "has its settings/config" do
    assert @account.config.present?
  end
end
