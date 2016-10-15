require 'test_helper'

class Teach::LecturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    sign_in_as(users(:professor))
  end
  
  test "start new lecture" do
    get new_teach_course_unit_lecture_url(@course, @unit), xhr: true
    assert_response :success
  end

  test "create lecture" do
    assert_difference('Lecture.count') do
      post teach_course_unit_lectures_url(@course, @unit), params: { 
        lecture: {name: 'l03', about: 'Lecture 03', based_on: Time.zone.today.strftime('%Y-%m-%d'),
          on_date: Time.zone.today.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show lecture" do
    get teach_course_unit_lecture_url(@course, @unit, @lecture)
    assert_response :success
    assert_select 'h2', /#{@unit.name}/
    assert_select 'a.item.active', /#{@lecture.name}/
  end

  test "start editing lecture" do
    get edit_teach_course_unit_lecture_url(@course, @unit, @lecture), xhr: true
    assert_response :success
  end

  test "update lecture" do
    patch teach_course_unit_lecture_url(@course, @unit, @lecture), params: {lecture: { about: 'the first lecture of this unit'}}, xhr: true
    assert_response :success
  end
  
  test "allow or disallow discussion" do
    put discuss_teach_course_unit_lecture_url(@course, @unit, @lecture)
    assert_redirected_to teach_course_unit_url(@course, @unit) 
    assert_not_equal @lecture.allow_discussion, Lecture.find(@lecture.id).allow_discussion
  end

  test "sort lectures" do 
    one = @unit.lectures.first
    two = @unit.lectures.last
    assert one.order < two.order
    post sort_teach_course_unit_lectures_url(@course, @unit), params: {lecture: [two.id, one.id]}, xhr: true
    assert_response :success
    assert Lecture.find(one.id).order > Lecture.find(two.id).order
  end
  
  test "destroy lecture" do
    assert_difference('Lecture.count', -1) do
      delete teach_course_unit_lecture_url(@course, @unit, @lecture)
    end

    assert_redirected_to teach_course_unit_url(@course, @unit)
  end
end
