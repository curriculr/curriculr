require 'test_helper'

class Teach::InstructorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    sign_in_as(users(:professor))
  end

  test "add new instructor" do
    get new_teach_course_instructor_url(@course), xhr: true
    assert_response :success
  end

  test "create instructor" do
    assert_difference('Instructor.count') do
      user = users(:one)
      post teach_course_instructors_url(@course), params: { 
        instructor: {name: user.name, email: user.email, role: 'technician', course_id: @course.id} 
      }, xhr: true
      assert_response :success
    end
  end

  test "should get edit" do
    get edit_teach_course_instructor_url(@course, @course.instructors.first), xhr: true
    assert_response :success
  end

  test "update instructor" do
    patch teach_course_instructor_url(@course, @course.instructors.last), params: {
      instructor: {role: 'technician'} 
    }, xhr: true
    assert_response :success
  end

  test "destroy instructor" do
    assert_difference('Instructor.count', -1) do
      delete teach_course_instructor_url(@course, @course.instructors.first)
    end

    assert_redirected_to teach_course_url(@course, show: :people)
  end
end
