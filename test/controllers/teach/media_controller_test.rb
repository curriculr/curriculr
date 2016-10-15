require 'test_helper'

class Teach::MediaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    sign_in_as(users(:professor))
  end

  test "load index page" do
    get teach_course_media_url(@course)
    assert_response :success
  end

  test "add new medium" do
    get new_teach_course_medium_url(@course), xhr: true
    assert_response :success
  end

  test "create medium" do
    assert_difference('Medium.count') do
      post teach_course_media_url(@course), params: { 
        medium: {kind: "video", name: "GOT Video", source: "youtube", "url"=>"bjD3OL8sTlQ"}
      }, xhr: true
      assert_response :success
    end
  end

  test "show medium" do
    get teach_course_medium_url(@course, @course.media.first)
    assert_redirected_to @course.media.first.at_url
  end

  test "start editing medium" do
    get edit_teach_course_medium_url(@course, @course.media.first), xhr: true
    assert_response :success
  end

  test "update medium" do
    patch teach_course_medium_url(@course, @course.media.first), params: { 
      medium: {kind: "video", name: "GOT Video", source: "youtube", "url"=>"bjD3OL8sTlQ"} 
    }, xhr: true
    assert_response :success
  end

  test "destroy medium" do
    kind = @course.media.last.kind
    assert_difference('Medium.count', -1) do
      delete teach_course_medium_url(@course, @course.media.last)
    end

    assert_redirected_to teach_course_media_url(@course, s: kind )
  end
end
