require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def setup
		@page = pages(:faq_eng101)
	end

	test "with valid fixtures" do
    assert pages(:faq_eng101).valid?
    assert pages(:notes_stat101).valid?
  end

  test "invalid without a name" do
  	@page.name = nil
  	assert_not @page.valid?
  end
  
  test "invalid without an about" do
    @page.about = nil
  	assert_not @page.valid?
  end
end
