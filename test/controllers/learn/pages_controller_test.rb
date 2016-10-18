require 'test_helper'

class Learn::PagesControllerTest < ActionDispatch::IntegrationTest
   setup do
     @user = users(:three)
     @course = courses(:eng101)
     @klass = @course.klasses.first
     @page = @course.non_syllabus_pages.first
     KlassEnrollment.enroll(@klass, @user.self_student)

     sign_in_as(@user)
   end

  test "load index page" do
    get learn_klass_pages_url(@klass)
    assert_response :success
  end

  test "show page" do
    get learn_klass_page_url(@klass, @page), xhr: true
    assert_response :success
  end
end
