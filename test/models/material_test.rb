require 'test_helper'

class MaterialTest < ActiveSupport::TestCase
  def setup
		@material = materials(:poster_eng101)
	end

	test "with valid fixtures" do
    assert materials(:poster_eng101).valid?
    assert materials(:promo_stat101).valid?
  end
  
  test "invalid without a kind" do
    @material.kind = nil
  	assert_not @material.valid?
  end    

  test "has a url" do
    assert @material.at_url.present?
  end
end
