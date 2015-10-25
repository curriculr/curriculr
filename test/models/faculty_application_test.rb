require 'test_helper'

class FacultyApplicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
		@faculty_application = faculty_applications(:one)
	end

	test "with a valid fixture" do
    assert @faculty_application.valid?
  end
end
