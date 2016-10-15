require 'test_helper'

class Teach::ForumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    sign_in_as(users(:professor))
  end

  test "start a new forum" do
    get new_teach_course_forum_url(@course), xhr: true
    assert_response :success
  end

  test "create forum" do
    assert_difference('Forum.count') do
      post teach_course_forums_url(@course), params: { 
        forum: {name: 'First forum', about: 'About first forum'}
      }, xhr: true
      assert_response :success
    end
  end

  test "start editing forum" do
    get edit_teach_course_forum_url(@course, @course.forums.first), xhr: true
    assert_response :success
  end

  test "update forum" do
    patch teach_course_forum_url(@course, @course.forums.first), params: {
      forum: {name: 'Some forum', about: 'About some forum'}
    }, xhr: true
    assert_response :success
  end

  test "destroy forum" do
    assert_difference('Forum.count', -1) do
      delete teach_course_forum_url(@course, @course.forums.first)
    end

    assert_redirected_to teach_course_url(@course, show: :forums)
  end
end
