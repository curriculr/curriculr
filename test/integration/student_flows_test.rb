require 'test_helper'

class StudentFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    @forum = forums(:general_eng101_sec01)
    KlassEnrollment.enroll(@klass, @user.self_student)

    login_as(@user, :scope => :user)
  end

  def teardown
    logout(:user)
  end

  test 'can enroll in a class' do
    klass = klasses(:eng101_sec02)
    visit learn_klasses_path

    click_link 'Learn more'
    click_link 'Enroll'
    check('agreed_to_klass_enrollment')

    click_button 'Submit'

    assert page.has_content?(klass.course.name)
  end

  test 'visit class' do
    visit learn_klass_path(@klass)

    assert page.has_content?(@course.name)
  end

  test 'visit lecture' do
    visit learn_klass_lecture_path(@klass, @lecture)

    assert page.has_content?(@lecture.name)
  end

  test 'can create a topic' do
    visit learn_klass_forum_path(@klass, @forum)

    assert page.has_content?(@forum.name)

    click_link 'New'

    name = Faker::Lorem.words(2).join(" ")
    fill_in 'topic_name', with: name
    fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(1).join("\n")
    check('topic_anonymous')

    click_button 'Create'

    assert page.has_content?(name)
  end

  test 'can view report' do
    visit report_learn_klass_path(@klass)

    # assert page.has_content?(@klass.name)
    #save_and_open_page
  end
end
