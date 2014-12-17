require 'spec_helper'


feature 'Instructors' do
  background do
    @instructor = create(:faculty, name: 'Instrucor Joe')
  end

  scenario 'can sign in' do
    visit new_user_session_path
    fill_in 'user_email', with: @instructor.email
    fill_in 'Password', with: @instructor.password
    click_button 'Login'
    
    expect(page).to have_content("Builder")
    expect(current_path).to eq home_path
  end

  
  scenario 'can list courses and create new one' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    expect(current_path).to eq home_path
    find(:xpath, "//a[@href='/teach/courses']").click
    expect(current_path).to eq teach_courses_path

    click_link 'New'
    expect(current_path).to eq new_teach_course_path

    fill_in 'course_slug', with: 'stat101'
    fill_in 'course_name', with: 'Statistics 101'
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(2).join("\n")
    fill_in 'course_weeks', with: 8
    fill_in 'course_workload', with: 5

    click_button 'Create'

    expect(page).to have_content('Statistics 101')
  end
end