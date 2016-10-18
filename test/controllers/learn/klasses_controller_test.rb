require 'test_helper'

class Learn::KlassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    KlassEnrollment.enroll(@klass, @user.self_student)

    sign_in_as(@user)
  end
  
  test "klasses" do
    get learn_klasses_url
    assert_response :success
  end

  test "show class not enrolled in" do
    get learn_klass_url(klasses(:eng101_sec01))
    assert_response :success
    assert_select 'nav div.header', false
  end
  
  test "show class enrolled in" do
    get learn_klass_url(@klass)
    assert_response :success
    assert_select 'nav div.header', /#{@klass.course.name}/
  end
  
  test "enroll in klass" do
    klass = klasses(:eng101_sec02)
    assert_difference('klass.enrollments.count') do
      post enroll_learn_klass_path(klass), xhr: true, params: {klasses: klass.id, agreed_to_klass_enrollment: 1}
      assert_response :success
    end
  end

  test "drop klass" do
    put drop_learn_klass_url(@klass)
    assert_redirected_to learn_klass_url(@klass)
  end
  
  test "unable to show klass students if not instructor" do
    get students_learn_klass_url(@klass)
    assert_redirected_to error_401_url
  end

  test "show klass students" do
    sign_in_as(users(:professor))
    get students_learn_klass_url(@klass)
    assert_response :success
  end
  
  test "klass student report" do
    get learn_klass_student_report_url(@klass, @user.self_student)
    assert_response :success
  end

  test "klass report" do
    get report_learn_klass_url(@klass)
    assert_response :success
  end
  
  test "klass search" do
    get learn_klass_search_url(@klass), params: {locale: {en: "English"}}, xhr: true
    assert_response :success
  end
end
