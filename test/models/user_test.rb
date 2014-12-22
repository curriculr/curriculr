require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "with valid fixtures" do
    assert users(:super).valid?
    assert users(:admin).valid?
    assert users(:professor).valid?
    assert users(:assistant).valid?
    assert users(:console).valid?
    assert users(:support).valid?
    assert users(:one).valid?
    assert users(:two).valid?
    assert users(:three).valid?
  end

  test "invalid without an email" do
    assert @user.valid?
    @user.email = nil
    assert_not @user.valid?
  end

  test "invalid without a name" do
    assert @user.valid?
    @user.name = nil
    assert_not @user.valid?
  end

  test "has a profile and a corresponding student" do
    assert_not_nil @user.profile
    assert_not_nil @user.self_student
  end
end
