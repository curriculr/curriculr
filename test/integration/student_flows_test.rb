require 'test_helper'

class StudentFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @forum = forums(:general_eng101_sec01)
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
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
       user: {email: @user.email, password: 'password'}}
    assert_redirected_to home_url
  end
  
  test 'cannot enroll in a class if not signed in' do
    sign_out
    
    get learn_klass_url(@klass)
    assert_response :success
    
    get enroll_learn_klass_url(@klass)
    assert_redirected_to auth_signin_url
  end
  
  test 'can enroll in a class' do
    klass = klasses(:eng101_sec02)
    get learn_klasses_path
    assert_response :success
    
    get learn_klass_path(klass)
    assert_response :success
    
    assert_difference('klass.enrollments.count') do
      post enroll_learn_klass_path(klass), xhr: true, params: {klasses: klass.id, agreed_to_klass_enrollment: 1}
      assert_response :success
    end
  end

  test 'visit class' do
    get learn_klass_path(@klass)
    assert_response :success
  end

  test 'visit lecture' do
    get learn_klass_lecture_path(@klass, @lecture)
    assert_response :success
    
    assert_select 'h2', /#{@lecture.name}/
  end

  test 'visit discussion' do
    get learn_klass_forums_path(@klass)
    assert_response :success
    
    assert_select 'h3', /Forums/
  end
  
  test 'visit assessments' do
    get learn_klass_assessments_path(@klass)
    assert_response :success
    assert_select 'h3', /Assessments/
  end
  
  test 'visit pages' do
    get learn_klass_pages_path(@klass)
    assert_response :success
  end
  
  test 'visit progress' do
    get report_learn_klass_path(@klass)
    assert_response :success
    assert_select 'div.label', "Final Score"
  end
  
  test 'can create a topic' do
    get learn_klass_forums_path(@klass)
    assert_response :success
    
    assert_difference ('@forum.topics.count') do 
      post url_for(controller: 'learn/topics', action: 'create', klass_id: @klass.id, forum_id: @forum.id), params: {
        topic: {name: "First topic", about: "About just anything"}
      }, xhr: true
      
      assert_response :success
    end
  end

  test 'can sign out' do
    get auth_signout_url
    assert_redirected_to auth_signin_url
    follow_redirect!
    assert_select 'div.message', /You are now signed out/
  end
end
