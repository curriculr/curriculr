require 'test_helper'

class InstructorFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @instructor = create(:faculty, name: 'Instructor Joe', email: 'foo@bar.com')
    @course = create(:course)
    @unit = create(:unit, course: @course)
    @lecture = create(:lecture)
    @course.update(originator: @instructor)
    @page = create(:page)
  end

  test 'can sign in' do
    visit new_user_session_path
    fill_in 'user_email', with: @instructor.email
    fill_in 'Password', with: @instructor.password
    click_button 'Login'
    
    expect(page).to have_content("Builder")
    expect(current_path).to eq home_path
  end

  test 'can list courses and create new one' do
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

  test 'can edit syllabus' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_page_path(@course, @course.syllabus)

    description = Faker::Lorem.paragraphs(3).join("\n")
    fill_in 'wmd-input', with: description

    click_button 'Update'

    expect(page).to have_content(description)
  end

  test 'can create assessment' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit new_teach_course_assessment_path(@course, t: 'final')

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_penalty', with: '5'
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 10.days.from_now
    fill_in 'assessment_allowed_attempts', with: '2'

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit assessment' do
    @assessment = create(:assessment, kind: 'final')
    @course.assessments << @assessment
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_assessment_path(@course, @assessment)
    
    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_penalty', with: '5'
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 15.days.from_now
    fill_in 'assessment_allowed_attempts', with: '5'

    click_button 'Update'

    expect(page).to have_content(name)
  end

  test 'can add people' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit new_teach_course_instructor_path(@course)

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'instructor_email', with: 'foo@bar.com'
    select('Assistant', :from => 'instructor_role')
    fill_in 'instructor_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit people' do
    user = create(:user)
    assisstant = create(:instructor, user: user, course: @course, email: 'foo@bar.com', role: 'Assistant')
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_instructor_path(@course, assisstant)

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'instructor_email', with: 'foo@bar.com'
    select('Assistant', :from => 'instructor_role')
    fill_in 'instructor_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Update'

    expect(page).to have_content(name)
  end

  # scenario 'can add books' do
  #   login_as(@instructor, :scope => :user)
  #   visit root_path
    
  #   visit teach_course_path(@course)

  #   visit new_teach_course_material_path(@course, s: 'document', t: 'books')

  #   save_and_open_page
  # end

  test 'can create a page' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit new_teach_course_page_path(@course)

    name = Faker::Lorem.words(3).join(" ")
    fill_in 'page_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit a page' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_page_path(@course, @page)

    name = Faker::Lorem.words(3).join(" ")
    fill_in 'page_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Update'

    expect(page).to have_content(name)
  end

  test 'can create a survey' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit new_teach_course_assessment_path(@course, t: 'survey')

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 10.days.from_now
    select('On class enrollment', :from => 'assessment_event_list')

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit an assessment' do
    @assessment = create(:assessment, kind: 'survey')
    @course.assessments << @assessment
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_assessment_path(@course, @assessment)
    
    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 10.days.from_now
    select('On class enrollment', :from => 'assessment_event_list')

    click_button 'Update'

    expect(page).to have_content(name)
  end

  test 'can create a unit' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit new_teach_course_unit_path(@course)

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'unit_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(2).join("\n")
    fill_in 'unit_on_date', with: Time.zone.today
    fill_in 'unit_for_days', with: '10'

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit a unit' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit edit_teach_course_unit_path(@course, @unit)

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'unit_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(2).join("\n")
    fill_in 'unit_on_date', with: Time.zone.today
    fill_in 'unit_for_days', with: '10'

    click_button 'Update'

    expect(page).to have_content(name)
  end

  test 'can create a lecture in the unit' do
    login_as(@instructor, :scope => :user)
    visit root_path

    visit teach_course_path(@course)

    visit new_teach_course_unit_lecture_path(@course, @unit)

    name = Faker::Lorem.words(2).join(' ')
    fill_in 'lecture_name', with: name
    fill_in 'lecture_about', with: Faker::Lorem.paragraphs(3).join("\n")
    fill_in 'lecture_on_date', with: Time.zone.today
    fill_in 'lecture_for_days', with: '15'
    fill_in 'lecture_points', with: '5'

    click_button 'Create'

    expect(page).to have_content(name)
  end

  # test 'can edit a lecture in the unit' do
  #   login_as(@instructor, :scope => :user)
  #   visit root_path
    
  #   visit teach_course_path(@course)

  #   visit edit_teach_course_unit_lecture_path(@course, @unit, @lecture)

  #   name = Faker::Lorem.words(2).join(' ')
  #   fill_in 'lecture_name', with: name
  #   fill_in 'lecture_about', with: Faker::Lorem.paragraphs(3).join("\n")
  #   fill_in 'lecture_on_date', with: Time.zone.today
  #   fill_in 'lecture_for_days', with: '15'
  #   fill_in 'lecture_points', with: '5'
  
  #   click_button 'Update'

  #   expect(page).to have_content(name)

  #   save_and_open_page
  # end

  test 'can create an assessment in the unit' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit  new_teach_course_unit_assessment_path(@course, @unit, t: 'quiz')

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_penalty', with: '5'
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 15.days.from_now
    fill_in 'assessment_allowed_attempts', with: '5'

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit an assessment in the unit' do
    @assessment = create(:assessment, kind: 'quiz')
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit  edit_teach_course_unit_assessment_path(@course, @unit, @assessment)

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'assessment_penalty', with: '5'
    fill_in 'assessment_name', with: name
    fill_in 'assessment_from_datetime', with: Time.zone.today
    fill_in 'assessment_to_datetime', with: 15.days.from_now
    fill_in 'assessment_allowed_attempts', with: '5'

    click_button 'Update'

    expect(page).to have_content(name)
  end

  test 'can create a page in the unit' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit  new_teach_course_unit_page_path(@course, @unit)

    name = Faker::Lorem.words(3).join(" ")
    fill_in 'page_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Create'

    expect(page).to have_content(name)
  end

  test 'can edit a page in the unit' do
    login_as(@instructor, :scope => :user)
    visit root_path
    
    visit teach_course_path(@course)

    visit  edit_teach_course_unit_page_path(@course, @unit, @page)

    name = Faker::Lorem.words(3).join(" ")
    fill_in 'page_name', with: name
    fill_in 'wmd-input', with: Faker::Lorem.paragraphs(3).join("\n")

    click_button 'Update'

    expect(page).to have_content(name)
  end

  # test 'can add a document in the unit' do
  #   login_as(@instructor, :scope => :user)
  #   visit root_path
    
  #   visit teach_course_path(@course)

  #   visit  new_teach_course_unit_material_path(@course, @unit, s: 'document')

  #   save_and_open_page
  # end

  # test 'can add a file' do
  #   login_as(@instructor, :scope => :user)
  #   visit root_path
    
  #   visit teach_course_path(@course)

  #   visit multi_new_teach_course_medium_path(@course)

  #   save_and_open_page
  # end
end
