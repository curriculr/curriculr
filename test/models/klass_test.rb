require 'test_helper'

class KlassTest < ActiveSupport::TestCase
	setup do
		@klass = klasses(:eng101_sec02)
	end

  test "with valid fixtures" do
    assert klasses(:eng101_sec01).valid?
    assert klasses(:eng101_sec02).valid?
    assert klasses(:stat101_sec01).valid?
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
    assert @klass.valid?
  end
  
  test "invalid when ends_on is before begins_on" do
  	@klass.begins_on = Time.zone.today
  	@klass.ends_on = 2.days.ago
    assert_not @klass.valid?
  end
end