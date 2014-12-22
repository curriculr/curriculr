require 'test_helper'

class StudentFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user, name: 'User Joe')
    @course = create(:course)
    @klass = @course.klasses.first
    @klass.update(approved: true)
    login_as(@user, :scope => :user)
    KlassEnrollment.enroll(@klass, @user.self_student)
  end

  test 'can sign in' do
    visit learn_klasses_path
    expect(page).to_not have_content("Builder")
    expect(page).to have_content("Classes")
  end

  test 'can enroll in a class' do
    course = create(:course)
    klass = course.klasses.first
    klass.update(approved: true)
    visit learn_klasses_path

    click_link 'Learn more'
    click_link 'Enroll in this class - It\'s free'
    check('agreed')
    click_button 'Submit'

    expect(page).to have_content(course.name)
  end

  test 'visit class' do
    visit learn_klass_path(@klass)

    # expect(page).to have_content(course.name)
  end

  test 'visit class syllabus' do
    visit learn_klass_page_path(@klass, @course.syllabus)

    expect(page).to have_content('Syllabus')
  end

  # test 'visit class syllabus' do
  #   visit learn_klass_lecture_path(@klass)

  #   save_and_open_page
  # end
