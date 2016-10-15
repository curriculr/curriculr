require 'test_helper'

class Admin::ConfigControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:super)
    sign_in_as(@admin)
  end
  test "edit configurations" do
    get admin_config_edit_url
    assert_response :success
  end

  test "update configurations" do
    post admin_config_url, params: {opr: "edit", key: "en", type: "text", value: "English", setting: "supported_locales"}
    assert_redirected_to admin_config_edit_url
  end
end
