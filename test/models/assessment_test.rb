require 'test_helper'

class AssessmentTest < ActiveSupport::TestCase
	def setup
		@assessment = assessments(:quiz_eng101)
	end

  test "with valid fixtures" do
    assert @assessment.valid?
  end

  test "invalid without a name" do
  	@assessment.name = nil
    assert_not @assessment.valid?
  end
  
  test "valid without about" do
    @assessment.about = nil
    assert @assessment.valid?
  end
  
  test "invalid if its name is more than 100 character" do
  	@assessment.name = '01234567890123456789012345678901234567890123456789' +
      '01234567890123456789012345678901234567890123456789 '
    assert_not @assessment.valid?
  end
  
  test "invalid if allowed_attempts <= 0" do
  	@assessment.allowed_attempts = 0
    assert_not @assessment.valid?
    @assessment.allowed_attempts = -1
    assert_not @assessment.valid?
  end
  
  test "invalid if penalty is not numeric or < 0" do
  	@assessment.penalty = 'x'
    assert_not @assessment.valid?
    @assessment.penalty = -1
    assert_not @assessment.valid?
  end
  
  test "invalid without a from_datetime" do
  	@assessment.from_datetime = nil
    assert_not @assessment.valid?
  end
  
  test "valid without a to_datetime" do
  	@assessment.to_datetime = nil
    assert @assessment.valid?
  end
  
  test "invalid if to_datetime is before from_datetime" do
  	@assessment.to_datetime = Time.zone.now - 2.days
    assert_not @assessment.valid?
  end
  
  test "invalid if either invideo_id or invideo_at is blank" do
  	@assessment.invideo_id = 1
  	@assessment.invideo_at = nil
    assert_not @assessment.valid?

    @assessment.invideo_id = nil
  	@assessment.invideo_at = 100
    assert_not @assessment.valid?
  end
  
  test "invalid if droppable_attempts < 0" do
  	@assessment.droppable_attempts = -1
    assert_not @assessment.valid?
  end
end
