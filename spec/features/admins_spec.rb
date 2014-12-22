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

  scenario 'can add a new user' do
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/users']").click

    click_link 'New'
    email = Faker::Lorem.word + "@bar.foo"
    fill_in 'Name', with: Faker::Lorem.words(2).join(' ')
    fill_in 'Email', with: email
    fill_in 'Password', with: 'a_secret'
    fill_in 'Confirm Password', with: 'a_secret'

    click_button 'Create'

    expect(page).to have_content(email)
  end

  scenario 'can grant user a faculty role' do
    instructor = create(:user, name: 'Instructor Jane')
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/users']").click

    find(:xpath, "//a[@href='/users/#{instructor.id}?opr=faculty']").click
    
    save_and_open_page
  end

  scenario 'can create an announcement' do
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/admin/announcements']").click

    click_link 'New'
    message = Faker::Lorem.words(5).join(" ")
    fill_in 'wmd-input', with: message
    fill_in 'announcement_starts_at', with: Time.zone.today
    fill_in 'announcement_ends_at', with: 20.days.from_now

    click_button 'Create'

    expect(page).to have_content(message)
  end

  scenario 'can edit an announcement' do
    announcement = create(:announcement)
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/admin/announcements']").click

    find(:xpath, "//a[@href='/admin/announcements/#{announcement.id}/edit']").click

    message = Faker::Lorem.words(4).join(" ")
    fill_in 'wmd-input', with: message

    click_button 'Update'

    expect(page).to have_content(message)
  end

  scenario 'can remove an announcement' do
    announcement = create(:announcement, message: 'This is the announcement', starts_at: Time.zone.today, ends_at: 20.days.from_now)
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/admin/announcements']").click

    find(:xpath, "//a[@href='/admin/announcements/#{announcement.id}']").click

    save_and_open_page
  end

  scenario 'can visit dashboard' do
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/admin/dashboard']").click
    
    expect(page).to have_content('Dashboard')
  end

  scenario 'can create a page' do
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/pages']").click

    click_link 'New'
    title = Faker::Lorem.words(2).join(' ')
    fill_in 'page_name', with: title
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")
    fill_in 'page_slug', with: Faker::Lorem.word

    click_button 'Create'

    expect(page).to have_content(title)
  end

  scenario 'can edit a page' do
    page = create(:page)
    login_as(@admin, :scope => :user)
    visit root_path

    find(:xpath, "//a[@href='/pages']").click

    find(:xpath, "//a[@href='/pages/:slug/edit']").click

    save_and_open_page
  end
end