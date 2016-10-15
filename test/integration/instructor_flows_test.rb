require 'test_helper'

class InstructorFlowsTest < ActionDispatch::IntegrationTest
  setup do 
    @course = courses(:eng101)
    @instructor = @course.originator
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @page = @course.pages.second

    sign_in_as(@instructor)
    get home_path
  end

  teardown do 
    sign_out
  end

  test 'can list courses and create new one' do
    get teach_courses_path
    assert_response :success
    assert_select '.item .content .header', @course.name
  end
  
  # test 'can list courses and create new one' do
  #   get new_teach
  #   # fill_in 'course_slug', with: 'chem101'
  #   # fill_in 'course_name', with: 'Chemistry 101'
  #   # fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(2).join("\n")
  #   # fill_in 'course_weeks', with: 8
  #   # fill_in 'course_workload', with: 5
  #   #
  #   # click_button 'Create'
  #   #
  #   # assert page.has_content?('Chemistry 101')
  # end
  #
  # test 'visit class syllabus' do
  #   visit teach_course_page_path(@course, @course.syllabus)
  #
  #   assert page.has_content?(@course.syllabus.name)
  # end
  #
  # test 'can edit syllabus' do
  #   visit teach_course_path(@course)
  #
  #   visit edit_teach_course_page_path(@course, @course.syllabus)
  #
  #   description = Faker::Lorem.paragraphs(3).join("\n")
  #   fill_in 'wmd-inputabout', with: description
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(description)
  # end
  #
  # test 'can create assessment' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_assessment_path(@course, t: 'final')
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'assessment_penalty', with: '5'
  #   fill_in 'assessment_name', with: name
  #   fill_in 'assessment_from_datetime', with: Time.zone.today
  #   fill_in 'assessment_to_datetime', with: 10.days.from_now
  #   fill_in 'assessment_allowed_attempts', with: '2'
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit assessment' do
  #   @assessment = assessments(:final_eng101)
  #
  #   visit teach_course_path(@course)
  #
  #   visit edit_teach_course_assessment_path(@course, @assessment)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'assessment_penalty', with: '5'
  #   fill_in 'assessment_name', with: name
  #   fill_in 'assessment_from_datetime', with: Time.zone.today
  #   fill_in 'assessment_to_datetime', with: 15.days.from_now
  #   fill_in 'assessment_allowed_attempts', with: '5'
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can add people' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_instructor_path(@course)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'instructor_email', with: 'one@bar.foo'
  #   select('Assistant', :from => 'instructor_role')
  #   fill_in 'instructor_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit people' do
  #   user = users(:three)
  #   assisstant = instructors(:instructor_eng101)
  #
  #   visit teach_course_path(@course)
  #
  #   visit edit_teach_course_instructor_path(@course, assisstant)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   select('Assistant', :from => 'instructor_role')
  #   fill_in 'instructor_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end
  #
  # # scenario 'can add books' do
  # #   visit teach_course_path(@course)
  #
  # #   visit new_teach_course_material_path(@course, s: 'document', t: 'books')
  #
  # #   save_and_open_page
  # # end
  #
  # test 'can create a page' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_page_path(@course)
  #
  #   name = Faker::Lorem.words(3).join(" ")
  #   fill_in 'page_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit a page' do
  #   visit teach_course_path(@course)
  #
  #   visit edit_teach_course_page_path(@course, @page)
  #
  #   name = Faker::Lorem.words(3).join(" ")
  #   fill_in 'page_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can create a survey' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_assessment_path(@course, t: 'survey')
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'assessment_name', with: name
  #   fill_in 'assessment_from_datetime', with: Time.zone.today
  #   fill_in 'assessment_to_datetime', with: 10.days.from_now
  #   select('On class enrollment', :from => 'assessment_event_list')
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can create a unit' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_unit_path(@course)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'unit_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(2).join("\n")
  #   fill_in 'unit_on_date', with: Time.zone.today
  #   fill_in 'unit_for_days', with: '10'
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit a unit' do
  #   visit teach_course_path(@course)
  #
  #   visit edit_teach_course_unit_path(@course, @unit)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'unit_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(2).join("\n")
  #   fill_in 'unit_on_date', with: Time.zone.today
  #   fill_in 'unit_for_days', with: '10'
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can create a lecture in the unit' do
  #   visit teach_course_path(@course)
  #
  #   visit new_teach_course_unit_lecture_path(@course, @unit)
  #
  #   name = Faker::Lorem.words(2).join(' ')
  #   fill_in 'lecture_name', with: name
  #   fill_in 'lecture_about', with: Faker::Lorem.paragraphs(3).join("\n")
  #   fill_in 'lecture_on_date', with: Time.zone.today
  #   fill_in 'lecture_for_days', with: '15'
  #   fill_in 'lecture_points', with: '5'
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # # test 'can edit a lecture in the unit' do
  # #   visit teach_course_path(@course)
  #
  # #   visit edit_teach_course_unit_lecture_path(@course, @unit, @lecture)
  #
  # #   name = Faker::Lorem.words(2).join(' ')
  # #   fill_in 'lecture_name', with: name
  # #   fill_in 'lecture_about', with: Faker::Lorem.paragraphs(3).join("\n")
  # #   fill_in 'lecture_on_date', with: Time.zone.today
  # #   fill_in 'lecture_for_days', with: '15'
  # #   fill_in 'lecture_points', with: '5'
  #
  # #   click_button 'Update'
  #
  # #   assert page.has_content?(name)
  #
  # #   save_and_open_page
  # # end
  #
  # test 'can create an assessment in the unit' do
  #   visit teach_course_path(@course)
  #
  #   visit  new_teach_course_unit_assessment_path(@course, @unit, t: 'quiz')
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'assessment_penalty', with: '5'
  #   fill_in 'assessment_name', with: name
  #   fill_in 'assessment_from_datetime', with: Time.zone.today
  #   fill_in 'assessment_to_datetime', with: 15.days.from_now
  #   fill_in 'assessment_allowed_attempts', with: '5'
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit an assessment in the unit' do
  #   @assessment = assessments(:problem_eng101)
  #
  #   visit teach_course_path(@course)
  #
  #   visit  edit_teach_course_unit_assessment_path(@course, @unit, @assessment)
  #
  #   name = Faker::Lorem.words(2).join(" ")
  #   fill_in 'assessment_penalty', with: '5'
  #   fill_in 'assessment_name', with: name
  #   fill_in 'assessment_from_datetime', with: Time.zone.today
  #   fill_in 'assessment_to_datetime', with: 15.days.from_now
  #   fill_in 'assessment_allowed_attempts', with: '5'
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can create a page in the unit' do
  #   visit teach_course_path(@course)
  #
  #   visit  new_teach_course_unit_page_path(@course, @unit)
  #
  #   name = Faker::Lorem.words(3).join(" ")
  #   fill_in 'page_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Create'
  #
  #   assert page.has_content?(name)
  # end
  #
  # test 'can edit a page in the unit' do
  #   visit teach_course_path(@course)
  #
  #   visit  edit_teach_course_unit_page_path(@course, @unit, @page)
  #
  #   name = Faker::Lorem.words(3).join(" ")
  #   fill_in 'page_name', with: name
  #   fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
  #
  #   click_button 'Update'
  #
  #   assert page.has_content?(name)
  # end

  # test 'can add a document in the unit' do
  #   visit teach_course_path(@course)

  #   visit  new_teach_course_unit_material_path(@course, @unit, s: 'document')

  #   save_and_open_page
  # end

  # test 'can add a file' do
  #   visit teach_course_path(@course)

  #   visit multi_new_teach_course_medium_path(@course)

  #   save_and_open_page
  # end
end
