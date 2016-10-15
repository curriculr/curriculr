require 'test_helper'

class Admin::AnnouncementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    
  end
  setup do
    @announcement = announcements(:maintenance)
    @admin = users(:super)
    sign_in_as(@admin)
  end
  
  teardown do
    sign_out
  end

  test "visit index page" do
    get admin_announcements_url
    assert_response :success
  end

  test "start new announcement" do
    get new_admin_announcement_url, xhr: true
    assert_response :success
  end

  test "create announcement" do
    assert_difference('Announcement.count') do
      post admin_announcements_url, params: {
        announcement: {message: "Site notice", starts_at: 2.days.from_now.strftime('%Y-%m-%d'), 
          ends_at: 5.days.from_now.strftime('%Y-%m-%d'), 
          suspended: "0"}
      }, xhr: true
    end

    assert_response :success
  end

  test "start editing announcement" do
    get edit_admin_announcement_url(@announcement), xhr: true
    assert_response :success
  end

  test "update announcement" do
    patch admin_announcement_url(@announcement), params: {announcement: {message: "Site notice"}}, xhr: true
    assert_response :success
    assert_equal "Site notice" , Announcement.find(@announcement.id).message
  end

  test "should destroy admin_announcement" do
    assert_difference('Announcement.count', -1) do
      delete admin_announcement_url(@announcement)
    end

    assert_redirected_to admin_announcements_url
  end
end
