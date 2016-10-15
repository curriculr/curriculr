require 'test_helper'

class User::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "load signin form" do
    get auth_signin_url
    assert_response :success
  end

  test "sign in" do
    post url_for(controller: 'auth/sessions', action: 'create'), params: {
       user: {email: 'three@bar.foo', password: 'password'}}
    assert_redirected_to home_url
  end
  
  test "sign out" do
    # assert_nil cookies[:auth_token]
     user = users(:three)
    # sign_in_as(user)
    # assert_not_nil cookies[:auth_token]
    
    get url_for(controller: 'auth/sessions', action: 'destroy'), params: {id: user.id}
    assert_nil cookies[:auth_token]

    assert_redirected_to auth_signin_path
  end
end
