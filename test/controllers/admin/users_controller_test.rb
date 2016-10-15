require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
     sign_in_as @user
  end

  test "should get new" do
    get new_admin_user_url, xhr: true
    assert_response :success
  end

  test "should create a user within own domain" do
    assert_difference('User.count') do
      post admin_users_url, params: { 
        user: {email: 'one@two.com', name: 'One Two', password: 'password', password_confirmation: 'password'}
      }, xhr: true
    end

    assert_response :success
  end
end
