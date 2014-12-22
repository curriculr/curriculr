require 'test_helper'

class InstructorTest < ActiveSupport::TestCase
  test "with valid fixtures" do
    assert instructors(:instructor_eng101).valid?
    assert instructors(:instructor_stat101).valid?
  end
end
