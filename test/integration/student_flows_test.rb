require 'test_helper'

class StudentFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    login_as(@user, :scope => :user)
    KlassEnrollment.enroll(@klass, @user.self_student)
  end

  test 'can sign in and sign out' do
    user = users(:two)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'Password', with: 'password'

    click_button 'Login'
    
    save_and_open_page
    assert page.has_content?(user.name)
    assert_equal home_path, current_path

    click_link "Sign out"
    assert_equal root_path, current_path
  end

  test 'can enroll in a class' do
    klass = klasses(:eng101_sec02)
    visit learn_klasses_path

    click_link 'Learn more'
    click_link 'Enroll in this class - It\'s free'
    check('agreed')
    click_button 'Submit'

    assert page.has_content?(klass.course.name)
  end

  test 'visit class' do
    visit learn_klass_path(@klass)

    assert page.has_content?(@course.name)
  end

  test 'visit class syllabus' do
    visit learn_klass_page_path(@klass, @course.syllabus)

    assert page.has_content?('Syllabus')
  end

  # test 'visit class syllabus' do
  #   visit learn_klass_lecture_path(@klass)

  #   save_and_open_page
  # end
end