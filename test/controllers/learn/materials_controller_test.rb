require 'test_helper'

class Learn::MaterialsControllerTest < ActionDispatch::IntegrationTest
   setup do
     @user = users(:three)
     @course = courses(:eng101)
     @klass = @course.klasses.first
     @material = @course.books.first
     KlassEnrollment.enroll(@klass, @user.self_student)

     sign_in_as(@user)
   end

  test "show material" do
    get learn_klass_material_url(@klass, @material)
    assert_redirected_to @material.at_url 
  end
end
