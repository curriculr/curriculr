require 'test_helper'

class AdminFlowsTest < ActionDispatch::IntegrationTest
  test "the truth" do
  	visit root_path
  	save_and_open_page
  	assert true
  end
end
