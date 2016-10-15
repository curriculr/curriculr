require 'test_helper'

class MediaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @medium = media(:document)
    sign_in_as(users(:super))
  end

  test "load index page" do
    get media_url
    assert_response :success
  end

  test "add new medium" do
    get new_medium_url, xhr: true
    assert_response :success
  end

  test "create medium" do
    assert_difference('Medium.count') do
      post media_url, params: { 
        medium: {kind: "video", name: "GOT Video", source: "youtube", "url"=>"bjD3OL8sTlQ"}
      }, xhr: true
      assert_response :success
    end
  end

  test "show medium" do
    get medium_url(@medium)
    assert_redirected_to @medium.at_url
  end

  test "start editing medium" do
    get edit_medium_url( @medium), xhr: true
    assert_response :success
  end

  test "update medium" do
    patch medium_url(@medium), params: { 
      medium: {kind: "video", name: "GOT Video", source: "youtube", "url"=>"bjD3OL8sTlQ"} 
    }, xhr: true
    assert_response :success
  end

  test "destroy medium" do
    kind = @medium.kind
    assert_difference('Medium.count', -1) do
      delete medium_url(@medium)
    end

    assert_redirected_to media_url(s: kind )
  end
end
