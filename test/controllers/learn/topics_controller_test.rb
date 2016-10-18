require 'test_helper'

class Learn::TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @forum = @klass.forums.first
    @topic = @forum.topics.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end

  test "start new topic" do
    get new_learn_klass_forum_topic_url(@klass, @forum), xhr: true
    assert_response :success
  end

  test "create topic" do
    assert_difference('Topic.count') do
      post learn_klass_forum_topics_url(@klass, @forum), params: { 
        topic: {name: "First topic", about: "About just anything", anonymous: true} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show topic" do
    assert_raises (ActionView::MissingTemplate) do
      get learn_klass_forum_topic_url(@klass, @forum, @topic)
    end
  end

  test "start editing topic" do
    get edit_learn_klass_forum_topic_url(@klass, @forum, @topic), xhr: true
    assert_response :success
  end

  test "update topic" do
    patch learn_klass_forum_topic_url(@klass, @forum, @topic), params: { 
      topic: {name: "First topic", about: "About just anything", anonymous: true} 
    }, xhr: true
    assert_response :success
  end

  test "destroy topic" do
    assert_difference('Topic.count', -1) do
      delete learn_klass_forum_topic_url(@klass, @forum, @topic)
    end

    assert_redirected_to learn_klass_forums_url(@klass)
  end
end
