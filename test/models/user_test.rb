require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = prepare(users(:one))
  end
  
  def prepare(user)
    user.password = 'password'
    user
  end
  
  test "with valid fixtures" do
    assert prepare(users(:super)).valid?
    assert prepare(users(:admin)).valid?
    assert prepare(users(:professor)).valid?
    assert prepare(users(:assistant)).valid?
    assert prepare(users(:console)).valid?
    assert prepare(users(:support)).valid?
    assert prepare(users(:one)).valid?
    assert prepare(users(:two)).valid?
    assert prepare(users(:three)).valid?
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
  
  test "first and last names" do
    assert_equal 'Student', @user.first_name
    assert_equal 'One', @user.last_name
  end
  
  test "being a student" do
    klass = klasses(:eng101_sec01)
    KlassEnrollment.enroll(klass, @user.self_student)
    assert klass.enrolled?(@user.self_student)
  end
end
