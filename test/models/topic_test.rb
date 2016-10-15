require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  setup do 
  	@topic = topics(:topic_general_eng101_sec01)
  end

  test "with valid fixtures" do
    assert @topic.valid?
  end

  test "invalid without name" do
  	@topic.name = nil
    assert_not @topic.valid?
  end
  
  test "invalid without about" do
  	@topic.about = nil
    assert_not @topic.valid?(:create)
  end
end
