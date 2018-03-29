require 'test_helper'

class GuestFlowsTest < ActionDispatch::IntegrationTest
  setup do
    #host! "localhost:3000"
  end

  test 'can visit front page' do
    get root_url
    assert_select '.jumbotron .container .huge.header', /Open and Interactive Learning/
  end

  test 'can visit blogs page' do
    get blogs_url
    assert_select '.jumbotron .container .huge.header', /Official Blog/
  end

  test 'can visit klasses page' do
    get learn_klasses_url
    assert_select 'main .eleven.column .segment h2', /Available classes/
  end
  
  test 'can visit signin page' do
    get auth_signin_url
    assert_select 'button', "Sign in"
  end

  test 'can visit signup page' do
    get auth_signup_url
    assert_select 'button', "Create an account"
  end

  test 'can visit about page' do
    get localized_page_path(:about)
    assert_select 'h2', /About/
  end

  test 'can visit contactus page' do
    get contactus_url, xhr: true
    assert_response :success
  end

  test 'can visit terms and conditions page' do
    get localized_page_path(:terms)
    assert_select 'h2', /Terms/
  end

  test 'can sign in as a student and then sign out' do
    user = users(:two)
    get auth_signin_url
    
    post url_for(controller: 'auth/sessions', action: 'create'), params: {
      user: {email: user.email, password: 'password'}}
    assert_redirected_to home_url

    follow_redirect!
    assert_response :success
    assert_select "h2", "Classes I'm taking"
    
    get url_for(controller: 'auth/sessions', action: 'destroy'), params: {id: user.id}
    assert_empty cookies[:auth_token]

    assert_redirected_to auth_signin_path
  end

  test 'can sign in as an instructor' do
    user = users(:professor)
    get auth_signin_url
    
    post url_for(controller: 'auth/sessions', action: 'create'), params: {
      user: {email: user.email, password: 'password'}}
    assert_redirected_to home_url

    follow_redirect!
    assert_response :success
    assert_select "h2", "Courses being worked on"
    
    get url_for(controller: 'auth/sessions', action: 'destroy'), params: {id: user.id}
    assert_empty cookies[:auth_token]

    assert_redirected_to auth_signin_path
  end

  test 'can sign in as an admin' do
    user = users(:super)
    get auth_signin_url

    post url_for(controller: 'auth/sessions', action: 'create'), params: {
      user: {email: user.email, password: 'password'}}
    assert_redirected_to home_url

    follow_redirect!
    assert_response :success
    assert_select "h3", "Activity counts"

    get url_for(controller: 'auth/sessions', action: 'destroy'), params: {id: user.id}
    assert_empty cookies[:auth_token]

    assert_redirected_to auth_signin_path
  end
end
