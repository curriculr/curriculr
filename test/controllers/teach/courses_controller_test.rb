require 'test_helper'

class Teach::CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    sign_in_as(users(:professor))
  end

  test "visit index page" do
    get teach_courses_url
    assert_response :success
  end

  test "start new course" do
    get new_teach_course_url, xhr: true
    assert_response :success
  end

  test " create course" do
    assert_difference('Course.count') do
      post teach_courses_url, params: { 
        course: {slug: 'slug', name: 'Math 101', about: 'About Math 101', locale: 'en', category_list: ["math"]} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show course" do
    get teach_course_url(@course)
    assert_response :success
  end

  test "start editing course" do
    get edit_teach_course_url(@course), xhr: true
    assert_response :success
  end

  test "update course" do
    patch teach_course_url(@course), params: { course: { category_list: ["english"]}}, xhr: true
    assert_response :success
  end

  test "should destroy teach_course" do
    assert_difference('Course.count', -1) do
      delete teach_course_url(@course)
    end

    assert_redirected_to teach_courses_url
  end
end
