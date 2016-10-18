require 'test_helper'

class Learn::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @forum = @klass.forums.first
    @topic = @forum.topics.first
    @post = @topic.posts.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end

  test "create post" do
    assert_difference('Post.count') do
      post learn_klass_forum_topic_posts_url(@klass, @forum, @topic), params: {
        post: {name: "First post", about: "just about anything", anonymous: true}
      }, xhr: true
      assert_response :success
    end
  end
  
  test "destroy post" do
    assert_difference('Post.count', -1) do
      delete learn_klass_forum_topic_post_url(@klass, @forum, @topic, @post)
    end

    assert_redirected_to learn_klass_forum_topic_path(@klass, @forum, @topic)
  end
end
