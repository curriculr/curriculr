require 'test_helper'

class UnitTest < ActiveSupport::TestCase
	def setup
		@course = courses(:eng101)
		@unit = @course.units.first
	end

	# Validations
  test "with valid fixtures" do
    assert @unit.valid?
  end

  test "invalid without a name" do
  	@unit.name = nil
  	assert_not @unit.valid?
  end
  
  test "invalid without an about" do
    @unit.about = nil
  	assert_not @unit.valid?
  end
  
  test "invalid without on_date" do
    @unit.on_date = nil
  	assert_not @unit.valid?
  end
  
  test "valid with  on_date = today" do
    @unit.on_date = Time.zone.today
  	assert @unit.valid?
  end
  
  test "invalid with on_date < today " do
  	@unit.on_date = 2.days.ago
  	assert_not @unit.valid?
  end
  
  test "valid without for_days" do
  	@unit.for_days = nil
  	assert @unit.valid?
  end
  
  test "is invalid with 0 for_days" do
    @unit.for_days = 0
  	assert_not @unit.valid?
  end    
  
  test "is invalid with < 0 for_days" do
    @unit.for_days = -1
  	assert_not @unit.valid?
  end

  # Methods and scopes
  test "lists open units" do
    klass = klasses(:stat101_sec01)
    course = klass.course

    unit = course.units.last

    u = unit.dup
    u.update(on_date: Time.zone.today)
    v = unit.dup
    v.update(on_date: 7.days.from_now)
    w = unit.dup
    w.update(on_date: 14.days.from_now)
    
    student = users(:one).self_student
    KlassEnrollment.enroll(klass, student)

    assert_equal 3, Unit.open(klass, student).to_a.count
  end
  
  test "checks if unit is open" do
    I18n.locale = :en
    klass = klasses(:stat101_sec01)
    course = klass.course
    unit = course.units.last

    u = unit.dup
    u.update(on_date: Time.zone.today)
    v = unit.dup
    v.update(on_date: 7.days.from_now)
    w = unit.dup
    w.update(on_date: 14.days.from_now)

    student = users(:one).self_student
    KlassEnrollment.enroll(klass, student)
    
    assert u.open?(klass) && !v.open?(klass) && !w.open?(klass)
  end
end
