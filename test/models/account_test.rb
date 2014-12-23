require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def setup
		@account = accounts(:main)
	end

	test "with valid fixtures" do
    assert accounts(:main).valid?
    assert accounts(:secondary).valid?
  end

  test "has its settings/config" do
    assert @account.config.present?
  end
end
