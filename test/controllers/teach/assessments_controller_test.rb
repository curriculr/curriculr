require 'test_helper'

class Teach::AssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @assessment = @course.assessments.where(unit_id: nil).first
    @u_assessment = @unit.assessments.where(lecture_id: nil).first
    @l_assessment = @lecture.assessments.first
    sign_in_as(users(:professor))
  end

  test "start new assessment" do
    get new_teach_course_assessment_url(@course), xhr: true
    assert_response :success
    
    get new_teach_course_unit_assessment_url(@course, @unit), xhr: true
    assert_response :success
    
    get new_teach_course_unit_lecture_assessment_url(@course, @unit, @lecture), xhr: true
    assert_response :success
  end

  test "create assessment" do
    assert_difference('Assessment.count') do
      post teach_course_assessments_url(@course), params: {
        assessment: {course_id: @course.id, kind: "mid-term", name: "Mid-term", 
          based_on: Time.zone.today.strftime('%Y-%m-%d'), from_datetime: 10.days.from_now.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Assessment.count') do
      post teach_course_unit_assessments_url(@course, @unit), params: {
        assessment: {course_id: @course.id, unit_id: @unit.id, kind: "quiz", name: "Quiz One", 
          based_on: Time.zone.today.strftime('%Y-%m-%d'), from_datetime: 10.days.from_now.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Assessment.count') do
      post teach_course_unit_lecture_assessments_url(@course, @unit, @lecture), params: {
        assessment: {course_id: @course.id, unit_id: @unit.id, lecture_id: @lecture.id, kind: "quiz", name: "Quiz One", 
          based_on: Time.zone.today.strftime('%Y-%m-%d'), from_datetime: 10.days.from_now.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
  end

  test "should show teach_course_assessment" do
    get teach_course_assessment_url(@course, @assessment)
    assert_response :success
    
    get teach_course_unit_assessment_url(@course, @unit, @u_assessment)
    assert_response :success
    
    get teach_course_unit_lecture_assessment_url(@course, @unit, @lecture, @l_assessment)
    assert_response :success
  end

  test "should get edit" do
    get edit_teach_course_assessment_url(@course, @assessment), xhr: true
    assert_response :success
    
    get edit_teach_course_unit_assessment_url(@course, @unit, @u_assessment), xhr: true
    assert_response :success
    
    get edit_teach_course_unit_lecture_assessment_url(@course, @unit, @lecture, @l_assessment), xhr: true
    assert_response :success
  end

  test "should update teach_course_assessment" do
    patch teach_course_assessment_url(@course, @assessment), params: {assessment: {kind: "mid-term"} }, xhr: true
    assert_response :success
    
    patch teach_course_unit_assessment_url(@course, @unit, @u_assessment), params: {assessment: {kind: "problem"} }, xhr: true
    assert_response :success
    
    patch teach_course_unit_lecture_assessment_url(@course, @unit, @lecture, @l_assessment), params: {assessment: {kind: "quiz"} }, xhr: true
    assert_response :success
  end

  test "destroy assessment" do
    assert_difference('Assessment.count', -1) do
      delete teach_course_assessment_url(@course, @assessment)
    end
    assert_redirected_to teach_course_url(@course, show: :assessments)
    
    assert_difference('Assessment.count', -1) do
      delete teach_course_unit_assessment_url(@course, @unit, @u_assessment)
    end
    assert_redirected_to teach_course_unit_url(@course, @unit, show: :assessments)
    
    assert_difference('Assessment.count', -1) do
      delete teach_course_unit_lecture_assessment_url(@course, @unit, @lecture, @l_assessment)
    end
    assert_redirected_to teach_course_unit_lecture_url(@course, @unit, @lecture, show: :assessments)
  end
end
