require 'test_helper'

class Auth::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "load signup form" do
    get auth_signup_url
    assert_response :success
  end

  test "sign up" do
    assert_difference('User.count') do
      post auth_registrations_url, params: {
        user: {email: 'one@two.com', name: 'One Two', password: 'password', password_confirmation: 'password'}}
    end

    assert_redirected_to auth_signin_url
  end

  test "load password edit page" do
    user = users(:two)
    get edit_auth_registration_url(user), xhr: true
    assert_redirected_to auth_signin_url
    
    sign_in_as(user)
    get edit_auth_registration_url(user), xhr: true
    assert_response :success
  end

  test "change own password" do
    user = users(:two)    
    sign_in_as(user)

    patch auth_registration_url(user), params: {
      user: {id: user.id,  current_password: 'password', password: 'password1', password_confirmation: 'password'}
    }, xhr: true
    assert_equal user.updated_at, User.find(user.id).updated_at
    
    patch auth_registration_url(user), params: { 
      user: {id: user.id,  current_password: 'password', password: 'password1', password_confirmation: 'password1'}
    }, xhr: true
    assert_response :success
    
    assert_not_equal user.updated_at, User.find(user.id).updated_at
  end
end
