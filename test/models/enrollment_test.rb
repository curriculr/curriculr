require 'test_helper'

class EnrollmentTest < ActiveSupport::TestCase
	def setup
    @klass = klasses(:stat101_sec01)
    @user = users(:one)
    @student = @user.self_student
    @enrollment = KlassEnrollment.enroll(@klass, @student)
  end

  test "increases klass total enrollments when created" do
    assert_equal 1, @klass.enrollments.count
    assert_equal 1, @klass.enrollments.where(active: true).count
  end

  test "decreases klass active enrollments when dropped" do
    assert_equal 1, @klass.enrollments.count
    assert_equal 1, @klass.enrollments.where(active: true).count
    KlassEnrollment.drop(@enrollment)
    assert_equal 1, @klass.enrollments.count
    assert_equal 0, @klass.enrollments.where(active: true).count
  end
end
