require 'test_helper'

class GuestFlowsTest < ActionDispatch::IntegrationTest
  test 'can visit front page' do
    visit root_path

    assert page.has_text?("Open and Interactive Learning")
  end

  test 'can visit blogs page' do
    visit blogs_path
    within 'h2' do
      assert page.has_content?("Official Blog")
    end
  end

  test 'can visit klasses page' do
    visit learn_klasses_path

    #save_and_open_page
    assert page.has_content?(klasses(:stat101_sec01).course.name)
  end

  test 'can visit signin page' do
    visit new_user_session_path

    assert_text("Sign in")
  end

  test 'can visit signup page' do
    visit new_user_registration_path

    assert_text("New Registration")
  end

  test 'can visit about page' do
    visit about_path
    
    assert page.has_content?("About") 
  end

  test 'can visit contactus page' do
    visit contactus_path

    assert page.has_content?("Contact us")
  end

  test 'can visit privacy page' do
    visit localized_page_path(:privacy)

    #save_and_open_page
    assert page.has_content?("Privacy") 
  end

  test 'can visit terms and conditions page' do
    visit localized_page_path(:terms)

    assert page.has_content?("Terms of service") 
  end

  test 'can register with a name, email and password' do
    visit new_user_registration_path
    fill_in "Name",                 :with => "John Smith "
    fill_in "Email",                 :with => "jsmith@example.com"
    fill_in "Password",              :with => "a_secret"
    fill_in "Confirm Password", :with => "a_secret"
    
    click_button "Create an account"
    
    assert page.html.has_content?("A message with a confirmation link has been sent to your email address.")
    assert_equal root_path, current_path
  end

  test 'can sign in' do
    user = students(:one)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'Password', with: 'password'

    click_button 'Login'
    
    save_and_open_page
    assert page.has_content?(user.name)
    assert_equal home_path, current_path
  end
end
