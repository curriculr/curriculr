require 'spec_helper'


feature 'Students' do
  background do
    @user = create(:user, name: 'User Joe')
  end

  scenario 'can sign in' do
    visit new_user_session_path
    fill_in 'user_email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Login'
    
    expect(page).to_not have_content("Builder")
    expect(page).to have_content("Classes")
    expect(current_path).to eq home_path
  end
end