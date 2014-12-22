require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  def setup
  	@student = students(:one)
	end

	test "with valid fixtures" do
    assert students(:super).valid?
    assert students(:admin).valid?
    assert students(:professor).valid?
    assert students(:assistant).valid?
    assert students(:console).valid?
    assert students(:support).valid?
    assert students(:one).valid?
    assert students(:two).valid?
    assert students(:three).valid?
  end
end
