require 'test_helper'

class AdminFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:super)
    sign_in_as(@admin)
  end

  teardown do
    sign_out
  end

  test 'can sign in' do
    sign_out
    
    get home_url
    assert_redirected_to auth_signin_url
    follow_redirect!
    assert_select 'div.message', /You must sign in first to access this page/
    post url_for(controller: 'auth/sessions', action: 'create'), params: {
       user: {email: @admin.email, password: 'password'}}
    assert_redirected_to home_url
  end
  
  test 'can list users' do
    get users_url
    assert_response :success
    assert_select 'h2', /Users/
  end

  test 'can grant user a faculty role' do
    instructor = users(:one)
    assert_not instructor.has_role?(:faculty)
    patch user_url(instructor), params: {user: {id: instructor.id}, opr: 'faculty' }, xhr: true
    assert_response :success
    assert User.find(instructor.id).has_role?(:faculty)
  end

  test 'can visit dashboard' do
    get home_url
    assert_response :success
    assert_select 'a.active.item', /Dashboard/
    assert_select 'h3', /Activity counts/
  end
  
  test 'can visit root and be routed to home' do
    get root_url
    assert_redirected_to home_url
    follow_redirect!
    assert_select 'a.active.item', /Dashboard/
    assert_select 'h3', /Activity counts/
  end
  
  test 'can sign out' do
    get auth_signout_url
    assert_redirected_to auth_signin_url
    follow_redirect!
    assert_select 'div.message', /You are now signed out/
  end
end
