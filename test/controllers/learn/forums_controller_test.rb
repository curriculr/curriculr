require 'test_helper'

class Learn::ForumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @forum = @klass.forums.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end

  test "load index page" do
    get learn_klass_forums_url(@klass)
    assert_response :success
  end

  test "show forum" do
    assert_raises(ActionController::UnknownFormat) do
      get learn_klass_forum_url(@klass, @forum)
    end
    
    get learn_klass_forum_url(@klass, @forum), xhr: true
    assert_response :success
  end
end
