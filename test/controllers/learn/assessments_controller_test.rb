require 'test_helper'

class Learn::AssessmentsControllerTest < ActionDispatch::IntegrationTest
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
  
  test "load index page" do
    get learn_klass_assessments_url(@klass)
    assert_response :success
  end
  
  test "show assessment" do
    assert_raises(ActionController::UnknownFormat) do
      get learn_klass_assessment_url(@klass, @assessment)
      get learn_klass_assessment_url(@klass, @u_assessment)
      get learn_klass_assessment_url(@klass, @l_assessment)
    end
    
    get learn_klass_assessment_url(@klass, @assessment), xhr: true
    assert_response :success
    
    get learn_klass_assessment_url(@klass, @u_assessment), xhr: true
    assert_response :success
    
    get learn_klass_assessment_url(@klass, @l_assessment), xhr: true
    assert_response :success
  end
end
