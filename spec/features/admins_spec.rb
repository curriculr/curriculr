require 'spec_helper'

feature 'Guests' do
  scenario 'can visit front page' do
    visit root_path
    expect(page).to have_text("Open Interactive Education")
  end

  scenario 'can visit blogs page' do
    visit blogs_path
    within 'h2' do
        expect(page).to have_content("Official Blog")
    end
  end

  scenario 'can visit klasses page' do
    course = create(:course)
    course.klasses.first.update(approved: true)    
    name = course.name
    visit learn_klasses_path
    expect(current_path).to eq learn_klasses_path
    #save_and_open_page
    expect(page).to have_content(name)
  end

  scenario 'can visit signin page' do
    visit new_user_session_path
    within 'h3' do
        expect(page).to have_content("Sign in")
    end
  end

  scenario 'can visit signup page' do
    visit new_user_registration_path
    within 'h3' do
        expect(page).to have_content("New Registration")
    end
  end

  scenario 'can visit about page' do
    visit about_path
    within 'h2' do expect(page).to have_content("About") end
  end

  scenario 'can visit contactus page' do
    visit contactus_path
    expect(page).to have_content("Contact us")
  end

  scenario 'can visit privacy page' do
    visit localized_page_path(:privacy)
    within 'h2' do expect(page).to have_content("Privacy") end
  end

  scenario 'can visit terms and conditions page' do
    visit localized_page_path(:terms)
    within 'h2' do expect(page).to have_content("Terms of service") end
  end
end


feature 'Admins' do
  background do
    @admin = create(:admin)
  end
  scenario 'Sign in' do
    visit new_user_session_path
    fill_in 'user_email', with: @admin.email
    fill_in 'Password', with: @admin.password
    click_button 'Login'
    
    expect(current_path).to eq learn_klasses_path
  end
  
  scenario 'admin can list users' do
    visit root_path
    click_link 'Login'
    fill_in 'user_email', with: @admin.email
    fill_in 'Password', with: @admin.password
    click_button 'Login'
    
    expect(current_path).to eq learn_klasses_path
    find(:xpath, "//a[@href='/users']").click

    click_link 'Edit', match: :first

    fill_in 'Name', with: 'Super Admin'
    #
    click_button 'Update'
    #save_and_open_page
    expect(User.unscoped.find(@admin.id).name).to eq 'Super Admin'
  end
end