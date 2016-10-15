require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  setup do
		@announcement = announcements(:maintenance)
	end

	test "with valid fixtures" do
    assert @announcement.valid?
  end
  
  test "validations" do
    @announcement.message = ''
    assert_not @announcement.valid?
    @announcement.message = 'Notice'
    
    @announcement.starts_at = nil
    @announcement.ends_at = nil
    assert_not @announcement.valid?
    @announcement.starts_at = 5.days.from_now
    
    @announcement.ends_at = nil
    assert_not @announcement.valid?
    @announcement.ends_at = 3.days.from_now
    
    assert_not @announcement.valid?
  end
end
