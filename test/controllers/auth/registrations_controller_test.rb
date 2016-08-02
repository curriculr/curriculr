require 'test_helper'

class User::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_registrations_new_url
    assert_response :success
  end

  test "should get create" do
    get user_registrations_create_url
    assert_response :success
  end

end
