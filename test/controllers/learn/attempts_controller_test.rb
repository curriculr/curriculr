require 'test_helper'

class Learn::AttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @assessment = @course.assessments.where(unit_id: nil).first
    @u_assessment = @unit.assessments.where(lecture_id: nil).first
    @l_assessment = @lecture.assessments.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end
  
  # test "start a new assessment attempt" do
  #   @assessment.q_selectors << q_selectors(:yes_no_final_stat101)
  #   get new_learn_klass_assessment_attempt_url(@klass, @assessment)
  #   assert_response :success
  # end

  # test "should get create" do
  #   get :create
  #   assert_response :success
  # end

  # test "should get show_answer" do
  #   get :show_answer
  #   assert_response :success
  # end

end
