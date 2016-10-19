require 'test_helper'

class Learn::AttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @assessment = @course.assessments.where(unit_id: nil).first
    @assessment.reset_counts
    
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end
  
  test "start a new assessment attempt" do
    assert_difference('Attempt.count', 1) do 
      get new_learn_klass_assessment_attempt_url(@klass, @assessment)
      assert_response :success
    end
  end

  test "save attempt" do
    get new_learn_klass_assessment_attempt_url(@klass, @assessment)
    assert_response :success
    
    attempt = Attempt.last
    question = @assessment.questions.first
    selected_option = question.options.first.option
    post learn_klass_assessment_attempts_url(@klass, @assessment), params: {attempt_id: attempt.id, commit: 'save',
      attempt: {"#{question.id}": selected_option}
    }
   assert_response :success
   assert_equal 1, Attempt.find(attempt.id).state
  end
  
  test "sbumit attempt" do
    get new_learn_klass_assessment_attempt_url(@klass, @assessment)
    assert_response :success
    
    attempt = Attempt.last
    question = @assessment.questions.first
    selected_option = question.options.first.option
    post learn_klass_assessment_attempts_url(@klass, @assessment), params: {attempt_id: attempt.id, commit: 'submit',
      attempt: {"#{question.id}": selected_option}
    }
    assert_response :success
    assert_equal 2, Attempt.find(attempt.id).state
  end
end
