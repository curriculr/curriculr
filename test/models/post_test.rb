require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup do 
  	@post = posts(:post_general_eng101_sec01)
  end

  test "with valid fixtures" do
    assert @post.valid?
  end
  
  test "invalid without about" do
  	@post.about = nil
    assert_not @post.valid?
  end
end
