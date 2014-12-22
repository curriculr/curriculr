require 'test_helper'

class GuestFlowsTest < ActionDispatch::IntegrationTest
  test 'can visit front page' do
    visit root_path
    expect(page).to have_text("Open Interactive Education")
  end

  test 'can visit blogs page' do
    visit blogs_path
    within 'h2' do
        expect(page).to have_content("Official Blog")
    end
  end

  test 'can visit klasses page' do
    course = create(:course)
    course.klasses.first.update(approved: true)    
    name = course.name
    visit learn_klasses_path
    expect(current_path).to eq learn_klasses_path
    #save_and_open_page
    expect(page).to have_content(name)
  end

  test 'can visit signin page' do
    visit new_user_session_path
    within 'h3' do
        expect(page).to have_content("Sign in")
    end
  end

  test 'can visit signup page' do
    visit new_user_registration_path
    within 'h3' do
        expect(page).to have_content("New Registration")
    end
  end

  test 'can visit about page' do
    visit about_path
    within 'h2' do expect(page).to have_content("About") end
  end

  test 'can visit contactus page' do
    visit contactus_path
    expect(page).to have_content("Contact us")
  end

  test 'can visit privacy page' do
    visit localized_page_path(:privacy)
    #save_and_open_page
    within 'h2' do expect(page).to have_content("Privacy") end
  end

  test 'can visit terms and conditions page' do
    visit localized_page_path(:terms)
    within 'h2' do expect(page).to have_content("Terms of service") end
  end

  test 'can register with a name, email and password' do
    visit new_user_registration_path
    fill_in "Name",                 :with => "John Smith "
    fill_in "Email",                 :with => "jsmith@example.com"
    fill_in "Password",              :with => "a_secret"
    fill_in "Confirm Password", :with => "a_secret"
    
    click_button "Create an account"
    
    expect(page.html).to have_content("A message with a confirmation link has been sent to your email address.")
    expect(current_path).to eq root_path
  end

  test 'can sign in' do
    user = create(:user, name: 'John Smith')
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'Password', with: user.password

    click_button 'Login'
    
    #save_and_open_page
    expect(page).to have_content 'John'
    expect(current_path).to eq home_path
  end
end
