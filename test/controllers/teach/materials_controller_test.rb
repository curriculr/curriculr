require 'test_helper'

class Teach::MaterialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:stat101)
    @unit = @course.units.first
    @lecture = @unit.lectures.first
    sign_in_as(users(:professor))
  end

  test "add a new material" do
    get new_teach_course_material_url(@course, s: 'video', t: 'promo')
    assert_response :success
    
    get new_teach_course_unit_material_url(@course, @unit, s: 'document', multiple: true)
    assert_response :success
    
    get new_teach_course_unit_lecture_material_url(@course, @unit, @lecture, s: 'other', multiple: true)
    assert_response :success
  end

  test "create single material" do
    assert_difference('Material.count') do
      post teach_course_materials_url(@course), params: {
        material: {kind: "video", tag_list: "promo", medium_id: media(:video_stat101).id} }
    end
    assert_redirected_to teach_course_url(@course)
    
    assert_difference('Material.count') do
      post teach_course_unit_materials_url(@course, @unit), params: {
        material: {kind: "document", medium_id: media(:document_stat101).id} }
    end
    assert_redirected_to teach_course_unit_url(@course, @unit)
    
    assert_difference('Material.count') do
      post teach_course_unit_lecture_materials_url(@course, @unit, @lecture), params: {
        material: {kind: "other", medium_id: media(:other_stat101).id} }
    end
    assert_redirected_to teach_course_unit_lecture_url(@course, @unit, @lecture)
  end
  
  test "create multiple materials" do
    assert_difference('Material.count') do
      post teach_course_unit_lecture_materials_url(@course, @unit, @lecture), params: {
        material: {kind: "other", medium_id: media(:other_stat101).id} 
      }, xhr: true
      assert_response :success
    end
    
    assert_difference('Material.count') do
      post teach_course_unit_lecture_materials_url(@course, @unit, @lecture), params: {
        material: {kind: "document", medium_id: media(:document_stat101).id} 
      }, xhr: true
      assert_response :success
    end
  end

  test "destroy material" do
    assert_difference('Material.count', -1) do
      delete teach_course_material_url(@course, materials(:promo_stat101))
    end

    assert_redirected_to teach_course_url(@course)
  end
end
