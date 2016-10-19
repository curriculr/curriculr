require 'test_helper'

class InstructorFlowsTest < ActionDispatch::IntegrationTest
  setup do 
    @course = courses(:eng101)
    @instructor = @course.originator
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @page = @course.pages.second

    sign_in_as(@instructor)
  end

  teardown do 
    sign_out
  end

  test 'can sign in' do
    sign_out
    
    get home_url
    assert_redirected_to auth_signin_url
    follow_redirect!
    assert_select 'div.message', /You must sign in first to access this page/
    post url_for(controller: 'auth/sessions', action: 'create'), params: {
       user: {email: @instructor.email, password: 'password'}}
    assert_redirected_to home_url
  end
  
  test 'can list courses and create new one' do
    get teach_courses_path
    assert_response :success
    assert_select '.item .content .header', @course.name

    get new_teach_course_url, xhr: true
    assert_response :success
    
    post teach_courses_url, params: {
      course: {slug: 'chem101', name: 'Chemistry 101', about: 'Consectetur Vulputate Dapibus Vehicula', locale: :en, weeks: 8, workload: 5}
    }, xhr: true
    assert_response :success
    
    c = Course.last
    assert c.name == 'Chemistry 101'
    get teach_course_url(c)
    assert_response :success
    assert_select 'nav .header', /#{c.name}/
  end

  test 'visit course syllabus' do
    get teach_course_page_url(@course, @course.syllabus)
    assert_response :success
    assert_select 'main', /#{@course.syllabus.about}/
  end
  
  test 'visit course lectures' do
    get teach_course_units_url(@course)
    assert_redirected_to teach_course_unit_url(@course, @course.units.first)
    follow_redirect!
    assert_select 'main', /A course is divided into/
  end
  
  test 'visit course files' do
    get teach_course_media_url(@course)
    assert_response :success
    assert_select 'main h2', /Files/
  end
  
  test 'visit course klasses' do
    get teach_course_klasses_url(@course)
    assert_response :success
    assert_select 'h2', /#{@course.klasses.last.slug}/
  end
  
  test 'visit course questions' do
    get teach_course_questions_url(@course)
    assert_response :success
    assert_select 'main', /A course might have many questions distributed across its units and lectures/
  end
  
  test 'visit course settings' do
    get settings_teach_course_url(@course)
    assert_response :success
    assert_select 'h2', /Course settings/
  end
  
  test 'can sign out' do
    get auth_signout_url
    assert_redirected_to auth_signin_url
    follow_redirect!
    assert_select 'div.message', /You are now signed out/
  end
end
