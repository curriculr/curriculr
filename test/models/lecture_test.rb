require 'test_helper'

class LectureTest < ActiveSupport::TestCase
	def setup
		@course = courses(:eng101)
		@unit = @course.units.first
		@lecture = @unit.lectures.first
	end

  # Validations  
  test "with valid fixtures" do
    assert @lecture.valid?
  end

  test "invalid without a name" do
  	@lecture.name = nil
  	assert_not @lecture.valid?
  end
  
  test "invalid without an about" do
    @lecture.about = nil
  	assert_not @lecture.valid?
  end
  
  test "invalid without on_date" do
    @lecture.on_date = nil
  	assert_not @lecture.valid?
  end
  
  test "valid with on_date = today" do
    @lecture.on_date = Time.zone.today
  	assert @lecture.valid?
  end
  
  test "invalid with on_date < today " do
  	@lecture.on_date = 2.days.ago
  	assert_not @lecture.valid?
  end
  
  test "valid without for_days" do
  	@lecture.for_days = nil
  	assert @lecture.valid?
  end
  
  test "is invalid with 0 for_days" do
    @lecture.for_days = 0
  	assert_not @lecture.valid?
  end    
  
  test "is invalid with < 0 for_days" do
    @lecture.for_days = -1
  	assert_not @lecture.valid?
  end

  # Methods and scopes
  test "lists lectures that are open for students" do
    klass = klasses(:stat101_sec01)
    course = klass.course

    unit = course.units.last

    student = users(:one).self_student

    enrollment = klass.enrollments.create(:student_id => student.id, :active => true)

    #puts unit.lectures.select('id, unit_id, based_on, on_date').to_a.to_yaml
    assert_equal 2, Lecture.open_4_students(klass, unit, student).to_a.count
  end
  
  test "checks attendance" do
    klass = klasses(:stat101_sec01)
    course = klass.course

    unit = course.units.last

    student = users(:one).self_student

    enrollment = klass.enrollments.create(:student_id => student.id, :active => true)

    assert_equal 4, Lecture.attendance(klass, student).to_a.count
  end
end