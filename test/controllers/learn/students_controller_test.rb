require 'test_helper'

class Learn::StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @course = courses(:eng101)
    @klass = @course.klasses.first
    @student = @user.dependents.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end

  test "load index page" do
    get learn_students_url
    assert_response :success
  end

  test "add new student" do
    get new_learn_student_url, xhr: true
    assert_response :success
  end

  test "create student" do
    assert_difference('Student.count') do
      post learn_students_url, params: {
        student: {name: 'Child One', relationship: 'child'} 
      }, xhr: true
      assert_response :success
    end
  end

  test "edit student" do
    get edit_learn_student_url(@student), xhr: true
    assert_response :success
  end

  test "update student" do
    patch learn_student_url(@student), params: {
      student: {name: 'Child One', relationship: 'child'} 
    }, xhr: true
    assert_response :success
  end

  test "destroy student" do
    assert_difference('Student.count', -1) do
      delete learn_student_url(@student)
    end

    assert_redirected_to learn_students_url
  end
end
