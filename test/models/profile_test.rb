require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test "with valid fixtures" do
    assert profiles(:super).valid?
    assert profiles(:admin).valid?
    assert profiles(:professor).valid?
    assert profiles(:assistant).valid?
    assert profiles(:console).valid?
    assert profiles(:support).valid?
    assert profiles(:one).valid?
    assert profiles(:two).valid?
    assert profiles(:three).valid?
  end
end
