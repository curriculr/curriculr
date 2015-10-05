require 'test_helper'

class FacultyApplicationsControllerTest < ActionController::TestCase
  setup do
    @faculty_application = faculty_applications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:faculty_applications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create faculty_application" do
    assert_difference('FacultyApplication.count') do
      post :create, faculty_application: {  }
    end

    assert_redirected_to faculty_application_path(assigns(:faculty_application))
  end

  test "should show faculty_application" do
    get :show, id: @faculty_application
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @faculty_application
    assert_response :success
  end

  test "should update faculty_application" do
    patch :update, id: @faculty_application, faculty_application: {  }
    assert_redirected_to faculty_application_path(assigns(:faculty_application))
  end

  test "should destroy faculty_application" do
    assert_difference('FacultyApplication.count', -1) do
      delete :destroy, id: @faculty_application
    end

    assert_redirected_to faculty_applications_path
  end
end
