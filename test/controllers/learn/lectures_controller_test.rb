require 'test_helper'

class Learn::LecturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end
  
  test "load index page" do
    get learn_klass_lectures_url(@klass)
    assert_redirected_to learn_klass_lecture_url(@klass, @lecture)
  end

  test "should get show" do
    get learn_klass_lecture_url(@klass, @lecture)
    assert_response :success
  end

  test "show_page" do
    get show_page_of_learn_klass_lecture_url(@klass, @lecture, @lecture.pages.first), xhr: true
    assert_response :success
  end
  
  test "show_assessment" do
    get show_assessment_of_learn_klass_lecture_url(@klass, @lecture, @lecture.assessments.first), xhr: true
    assert_response :success
  end
  
  test "show_material" do
    @lecture.materials.create(medium: @course.media.first, kind: @course.media.first.kind)
    get show_material_of_learn_klass_lecture_url(@klass, @lecture, @lecture.materials.first), xhr: true
    assert_response :success
  end

  test "show_question" do
    get show_question_of_learn_klass_lecture_url(@klass, @lecture, @lecture.questions.first), xhr: true
    assert_response :success
  end



end
