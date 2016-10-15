require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  setup do 
  	@forum = forums(:general_eng101_sec01)
  end

  test "with valid fixtures" do
    assert @forum.valid?
  end

  test "invalid without name" do
  	@forum.name = nil
    assert_not @forum.valid?
  end
  
  test "invalid without about" do
  	@forum.about = nil
    assert_not @forum.valid?
  end
end