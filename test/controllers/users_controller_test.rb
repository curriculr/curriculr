require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:super)
    sign_in_as @user
  end
  
  test "should get index" do
    get users_url
    assert_response :success
    assert_select 'main h2', 'Users'
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user), xhr: true
    assert_response :success
  end

  test "should update self" do
    @user = users(:two)
    sign_in_as @user
    patch user_url(@user), params: {user: {id: @user.id, name: 'Super User Me' }}, xhr: true
    assert_response :success
    assert_equal 'Super User Me', User.find(@user.id).name
  end

  test "super user should be add role to a user" do
    one = users(:one)
    assert_not one.has_role?(:team)
    patch user_url(one), params: {id: one.id, opr: 'team' }, xhr: true
    assert_response :success
    assert User.find(one.id).has_role?(:team)
  end
  
  test "super user should be able to destroy user" do
    assert_difference('User.count', -1) do
      delete user_url(users(:one))
    end

    assert_redirected_to users_url
  end
  
  test "should destroy user" do
    sign_in_as users(:two)
    assert_no_difference('User.count') do
      delete user_url(users(:one))
    end

    assert_redirected_to error_401_url
  end
end
