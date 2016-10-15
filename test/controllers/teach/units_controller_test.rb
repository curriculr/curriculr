require 'test_helper'

class Teach::UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @unit = @course.units.first
    sign_in_as(users(:professor))
  end

  test "visit index page" do
    get teach_course_units_url(@course)
    assert_redirected_to teach_course_unit_url(@course, @course.units.first)
  end

  test "start new unit" do
    get new_teach_course_unit_url(@course), xhr: true
    assert_response :success
  end

  test " create unit" do
    assert_difference('Unit.count') do
      post teach_course_units_url(@course), params: { 
        unit: {name: 'u03', about: 'Unit 03', based_on: Time.zone.today.strftime('%Y-%m-%d'),
          on_date: Time.zone.today.strftime('%Y-%m-%d')} 
      }, xhr: true
      assert_response :success
    end
  end
  
  test "show unit" do
    get teach_course_unit_url(@course, @unit)
    assert_response :success
    assert_select 'h2', /#{@unit.name}/
  end

  test "start editing unit" do
    get edit_teach_course_unit_url(@course, @unit), xhr: true
    assert_response :success
  end

  test "update unit" do
    patch teach_course_unit_url(@course, @unit), params: { unit: { about: 'the first unit'}}, xhr: true
    assert_response :success
  end
  
  test "sort units" do 
    one = @course.units.first
    two = @course.units.last
    assert one.order < two.order
    post sort_teach_course_units_url(@course), params: {unit: [two.id, one.id]}, xhr: true
    assert_response :success
    assert Unit.find(one.id).order > Unit.find(two.id).order
  end

  test "destroy unit" do
    assert_difference('Unit.count', -1) do
      delete teach_course_unit_url(@course, @unit)
    end

    assert_redirected_to teach_course_units_url(@course)
  end

end
