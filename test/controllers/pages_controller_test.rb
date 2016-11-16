require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:blogger))
    @page = pages(:blog_post_1)
  end

  test "start a new page" do
    get new_page_url, xhr: true
    assert_response :success
  end

  test "create page" do
    assert_difference('Page.count') do
      post pages_url, params: { 
        page: {name: 'Course page', about: 'About course page', blog: true} 
      }, xhr: true
      assert_response :success
    end
  end

  test "show page" do
    get page_url(@page)
    assert_response :success
  end

  test "start editing page" do
    get edit_page_url(@page), xhr: true
    assert_response :success
  end

  test "update page" do
    patch page_url(@page), params: { 
        page: {name: 'blog page', about: 'About blog page', blog: true} 
    }, xhr: true
    assert_response :success
  end

  test "destroy page" do
    assert_difference('Page.count', -1) do
      delete page_url(@page)
    end
    assert_redirected_to pages_url
  end
end
