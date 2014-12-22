require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  def setup
		@announcement = announcements(:maintenance)
	end

	test "with valid fixtures" do
    assert @announcement.valid?
  end
end
