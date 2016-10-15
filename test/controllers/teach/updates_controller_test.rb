require 'test_helper'

class Teach::UpdatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @klass = @course.klasses.first
    @unit = @course.units.first
    sign_in_as(users(:professor))
  end

  test "add a new update" do
    get new_teach_course_update_url(@course), xhr: true
    assert_response :success
    
    get new_teach_course_klass_update_url(@course, @klass), xhr: true
    assert_response :success
    
    get new_teach_course_unit_update_url(@course, @unit), xhr: true
    assert_response :success
  end

  test "create update" do
    assert_difference('Update.count') do
      post teach_course_updates_url(@course), params: {
        update: {to: "students", www: "1", email: "0", subject: "Initial class update", body: "body fo initial update", active: "0"}  
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Update.count') do
      post teach_course_klass_updates_url(@course, @klass), params: {
        update: {to: "students", www: "1", email: "0", subject: "Initial class update", body: "body fo initial update", active: "0"}  
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Update.count') do
      post teach_course_unit_updates_url(@course, @unit), params: {
        update: {to: "students", www: "1", email: "0", subject: "Initial class update", body: "body fo initial update", active: "0"}  
      }, xhr: true
      assert_response :success
    end
  end

  test "should get edit" do
    get edit_teach_course_update_url(@course, @course.updates.first), xhr: true
    assert_response :success
    
    get edit_teach_course_klass_update_url(@course, @klass, @klass.updates.first), xhr: true
    assert_response :success
    
    get edit_teach_course_unit_update_url(@course, @unit, @unit.updates.first), xhr: true
    assert_response :success
  end

  test "update" do
    patch teach_course_update_url(@course, @course.updates.first), params: {
      update: {to: "students", www: "1", email: "0", subject: "Welcome", body: "body", active: "1"} 
    }, xhr: true
    assert_response :success
    
    patch teach_course_klass_update_url(@course, @klass, @klass.updates.first), params: {
      update: {to: "students", www: "1", email: "0", subject: "Welcome", body: "body", active: "1"} 
    }, xhr: true
    assert_response :success
    
    patch teach_course_unit_update_url(@course, @unit, @unit.updates.first), params: {
      update: {to: "students", www: "1", email: "0", subject: "Welcome", body: "body", active: "1"} 
    }, xhr: true
    assert_response :success
  end

  test "destroy update" do
    assert_difference('Update.count', -1) do
      delete teach_course_update_url(@course, @course.updates.first)
    end
    assert_redirected_to teach_course_url(@course, show: :updates)
    
    assert_difference('Update.count', -1) do
      delete teach_course_klass_update_url(@course, @klass, @klass.updates.first)
    end
    assert_redirected_to teach_course_klass_url(@course, @klass, show: :updates)
    
    assert_difference('Update.count', -1) do
      delete teach_course_unit_update_url(@course, @unit, @unit.updates.first)
    end
    assert_redirected_to teach_course_unit_url(@course, @unit, show: :updates)
  end
end
