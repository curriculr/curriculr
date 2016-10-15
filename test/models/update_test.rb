require 'test_helper'

class UpdateTest < ActiveSupport::TestCase
	setup do
		@update = updates(:one)
	end

  test "with valid fixtures" do
    assert updates(:one).valid?
    assert updates(:two).valid?
  end

  test "invalid without a subject if www" do
  	@update.subject = nil
  	@update.www = true

    assert_not @update.valid?
  end

  test "invalid without a subject if email" do
  	@update.subject = nil
  	@update.www = false
  	@update.email = true

    assert_not @update.valid?
  end
  
  test "invalid without a body" do
    @update.body = nil

    assert_not @update.valid?
  end
  
  test "invalid without a target" do
  	@update.to = nil

    assert_not @update.valid?
  end
end
