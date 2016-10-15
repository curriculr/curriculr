require 'test_helper'

class Auth::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "load password reset page" do
    get new_auth_password_reset_url
    assert_response :success
  end

  test "request password reset" do
    user = users(:three)
    assert_nil user.password_reset_token
    post url_for(controller: 'auth/password_resets', action: 'create'), params: {
      user: {email: user.email} }
    assert_redirected_to auth_signin_path
    assert_not_nil  User.find(user.id).password_reset_token
    
  end

  test "get the password reset page" do
    user = users(:three)
    assert_nil user.password_reset_token
    post url_for(controller: 'auth/password_resets', action: 'create'), params: {
      user: {email: user.email} }
      
    token = User.find(user.id).password_reset_token
    get url_for(controller: 'auth/password_resets', action: 'edit', id: token)
    assert_response :success
  end

  test "create a new password" do
    user = users(:three)
    assert_nil user.password_reset_token
    post url_for(controller: 'auth/password_resets', action: 'create'), params: {
      user: {email: user.email} }
      
    user = User.find(user.id)
    token = user.password_reset_token
    patch url_for(controller: 'auth/password_resets', action: 'update', id: token), params: {
      user: {password_reset_token: token, password: 'password1', password_confirmation: 'password1'}}
    
    assert_redirected_to auth_signin_url
    assert_not_equal user.updated_at, User.find(user.id).updated_at
  end
end
