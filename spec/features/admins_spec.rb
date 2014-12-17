require 'spec_helper'


feature 'Admins' do
  background do
    @admin = create(:admin, name: 'Just An Admin')
  end

  scenario 'can sign in' do
    visit new_user_session_path
    fill_in 'user_email', with: @admin.email
    fill_in 'Password', with: @admin.password
    click_button 'Login'
    
    expect(page).to have_content("Administration")
    expect(current_path).to eq home_path
  end

  
  scenario 'can list users' do
    login_as(@admin, :scope => :user)
    visit root_path
    
    expect(current_path).to eq home_path
    find(:xpath, "//a[@href='/users']").click

    #save_and_open_page

    find(:xpath, "//a[@href='/users/#{@admin.id}/edit']").click

    fill_in 'Name', with: 'Mighty Admin'

    click_button 'Update'
    
    expect(User.find(@admin.id).name).to eq 'Mighty Admin'
  end
end