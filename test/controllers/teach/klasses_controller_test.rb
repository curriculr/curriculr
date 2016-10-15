require 'test_helper'

class Teach::KlassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:eng101)
    @klass = @course.klasses.first
    sign_in_as(users(:assistant))
  end

  test "load index page" do
    get teach_course_klasses_url(@course)
    assert_response :success
  end

  test "start a new klass" do
    get new_teach_course_klass_url(@course), xhr: true
    assert_response :success
  end

  test "create klass" do
    assert_difference('Klass.count') do
      post teach_course_klasses_url(@course), params: { 
        klass: {slug: "sec03", begins_on: Time.zone.today.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show klass" do
    get teach_course_klass_url(@course, @klass)
    assert_response :success
  end

  test "start editing klass" do
    get edit_teach_course_klass_url(@course, @klass), xhr: true
    assert_response :success
  end

  test "update klass" do
    patch teach_course_klass_url(@course, @klass), params: {
      klass: {ends_on: 30.days.from_now.strftime('%Y-%m-%d')}
    }, xhr: true
    assert_response :success
  end
  
  test "unable to approve klass as instructor" do
    approved = @klass.approved
    put approve_teach_course_klass_url(@course, @klass)
    assert_response :success
    assert_equal approved, Klass.find(@klass.id).approved
  end
  
  test "approve klass as admin" do
    sign_in_as(users(:super))
    approved = @klass.approved
    put approve_teach_course_klass_url(@course, @klass)
    assert_redirected_to teach_course_klasses_path(@course)
    assert_not_equal approved, Klass.find(@klass.id).approved
  end
  
  test "making klass ready" do
    ready_to_approve = @klass.ready_to_approve
    put ready_teach_course_klass_url(@course, @klass)
    assert_redirected_to teach_course_klasses_path(@course)
    assert_not_equal ready_to_approve, Klass.find(@klass.id).ready_to_approve
  end

  test "destroy klass" do
    assert_difference('Klass.count', -1) do
      delete teach_course_klass_url(@course, @klass)
    end

    assert_redirected_to teach_course_path(@course)
  end
end
