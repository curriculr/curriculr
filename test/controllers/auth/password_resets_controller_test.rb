require 'test_helper'

class User::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_password_resets_new_url
    assert_response :success
  end

  test "should get create" do
    get user_password_resets_create_url
    assert_response :success
  end

end
