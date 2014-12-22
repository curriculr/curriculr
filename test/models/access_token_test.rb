require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase
  test "with valid fixtures" do
    assert access_tokens(:console).valid?
  end
end
