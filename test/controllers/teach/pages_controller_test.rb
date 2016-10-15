require 'test_helper'

class Teach::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @unit = @course.units.first
    @lecture = @unit.lectures.last
    sign_in_as(users(:professor))
  end

  test "start a new page" do
    get new_teach_course_page_url(@course), xhr: true
    assert_response :success

    get new_teach_course_unit_page_url(@course, @unit), xhr: true
    assert_response :success

    get new_teach_course_unit_lecture_page_url(@course, @unit, @lecture), xhr: true
    assert_response :success
  end

  test "create page" do
    assert_difference('Page.count') do
      post teach_course_pages_url(@course), params: { 
        page: {name: 'Course page', about: 'About course page'} 
      }, xhr: true
      assert_response :success
    end

    assert_difference('Page.count') do
      post teach_course_unit_pages_url(@course, @unit), params: { 
        page: {name: 'Course page', about: 'About course page'} 
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Page.count') do
      post teach_course_unit_lecture_pages_url(@course, @unit, @lecture), params: { 
        page: {name: 'Course page', about: 'About course page'} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show page" do
    get teach_course_page_url(@course, @course.pages.first)
    assert_response :success
    
    get teach_course_unit_page_url(@course, @unit, @unit.pages.first)
    assert_response :success
    
    get teach_course_unit_lecture_page_url(@course, @unit, @lecture, @lecture.pages.first)
    assert_response :success
  end

  test "start editing page" do
    get edit_teach_course_page_url(@course, @course.pages.first), xhr: true
    assert_response :success
    
    get edit_teach_course_unit_page_url(@course, @unit, @unit.pages.first), xhr: true
    assert_response :success
    
    get edit_teach_course_unit_lecture_page_url(@course, @unit, @lecture, @lecture.pages.first), xhr: true
    assert_response :success
  end

  test "update page" do
    patch teach_course_page_url(@course, @course.pages.first), params: { 
        page: {name: 'Course page', about: 'About course page'} 
    }, xhr: true
    assert_response :success
    
    patch teach_course_unit_page_url(@course, @unit, @unit.pages.first), params: { 
        page: {name: 'Course page', about: 'About course page'} 
    }, xhr: true
    assert_response :success
    
    patch teach_course_unit_lecture_page_url(@course, @unit, @lecture, @lecture.pages.first), params: { 
        page: {name: 'Course page', about: 'About course page'} 
    }, xhr: true
    assert_response :success
  end

  test "destroy page" do
    assert_difference('Page.count', -1) do
      delete teach_course_page_url(@course, @course.pages.first)
    end
    assert_redirected_to teach_course_url(@course, show: :pages)
    
    assert_difference('Page.count', -1) do
      delete teach_course_unit_page_url(@course, @unit, @unit.pages.first)
    end
    assert_redirected_to teach_course_unit_url(@course, @unit, show: :pages)
    
    assert_difference('Page.count', -1) do
      delete teach_course_unit_lecture_page_url(@course, @unit, @lecture, @lecture.pages.first)
    end
    assert_redirected_to teach_course_unit_lecture_url(@course, @unit, @lecture, show: :read)
  end
end
