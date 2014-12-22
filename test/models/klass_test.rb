require 'test_helper'

class KlassTest < ActiveSupport::TestCase
	def setup
		@klass = klasses(:eng101_sec02)
	end

  test "with valid fixtures" do
    assert @klass.valid?
  end

  test "valid without an about" do
  	@klass.about = nil
    assert @klass.valid?
  end
  
  test "invalid without begins_on" do
    @klass.begins_on = nil
    assert_not @klass.valid?
  end
  
  test "valid without ends_on" do
    @klass.ends_on = nil
    assert_not @klass.valid?
  end
  
  test "invalid when begins_on is before today" do
  	@klass.begins_on = 2.days.ago
  	@klass.based_on = Time.zone.today
    assert_not @klass.valid?
  end
  
  test "invalid when ends_on is before begins_on" do
  	@klass.begins_on = Time.zone.today
  	@klass.ends_on = 2.days.ago
    assert_not @klass.valid?
  end
end