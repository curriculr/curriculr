require 'test_helper'

class Teach::QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    sign_in_as(users(:professor))
  end

  test "load index page" do
    get teach_course_questions_url(@course)
    assert_response :success
  end

  test "start a new question" do
    get new_teach_course_question_url(@course, s: 'fill_one'), xhr: true
    assert_response :success
  end

  test "create a question" do
    assert_difference('Question.count') do
      post teach_course_questions_url(@course), params: {
        question: {course_id: @course.id, kind: "fill_one", question: "This?", bank_list: ["", "main"],
          options_attributes: {"0" => {"option"=>"that"}}} 
      }, xhr: true
      assert_response :success
    end
  end

  test "start editing question" do
    get edit_teach_course_question_url(@course, @course.questions.first), xhr: true
    assert_response :success
  end

  test "update question" do
    patch teach_course_question_url(@course, @course.questions.first), params: {
        question: {course_id: @course.id, kind: "fill_one", question: "This?", bank_list: ["", "main"],
          options_attributes: {"0" => {"option"=>"that"}}} 
      }, xhr: true
    assert_response :success
  end

  test "destroy question" do
    kind = @course.questions.first.kind
    assert_difference('@course.questions.count', -1) do
      delete teach_course_question_url(@course, @course.questions.first)
    end

    assert_redirected_to teach_course_questions_url(@course, s: kind)
  end
end
