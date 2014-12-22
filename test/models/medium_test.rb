require 'test_helper'

class MediumTest < ActiveSupport::TestCase
  def setup
		@medium = media(:video_eng101)
	end

	test "with valid fixtures" do
    assert media(:video_eng101).valid?
    assert media(:audio_eng101).valid?
    assert media(:image_eng101).valid?
    assert media(:document_stat101).valid?
    assert media(:other_stat101).valid?
  end

  test "invalid without a name" do
  	@medium.name = nil
  	assert_not @medium.valid?
  end
  
  test "invalid without a kind" do
    @medium.kind = nil
  	assert_not @medium.valid?
  end    
  
  test "invalid without a path and a url" do
  	@medium.url = nil
  	@medium.path = nil
  	assert_not @medium.valid?
  end
  
  test "valid without a path but with a url" do
  	@medium.path = nil
  	@medium.url = 'http://www.google.com'
  	assert @medium.valid?
	end

  test "has a url" do
    assert @medium.at_url.present?
  end
end