require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
  	@admin = users(:super)
  	@account = @admin.account
    @course_x = courses(:eng101)
    @instructor_x = @course_x.originator
    
    @course_y = courses(:stat101)
    @instructor_y = @course_y.originator
    
    @aAbility = Ability.new($account, @admin)
    @fxAbility = Ability.new($account, @instructor_x, @instructor_x.self_student, @course_x)
    @fyAbility = Ability.new($account, @instructor_y, @instructor_y.self_student, @course_y)

    @klass_x = @course_x.klasses.last
    @klass_y = @course_y.klasses.last

    @student = users(:one)
    @guest = nil
  end

  # Admin
	test 'admins can do anything' do
	  assert @aAbility.can?(:manage, :all)
	end
  
	# Faculty
  test "faculty can manage everything on her course" do
    assert @fxAbility.can?(:manage, @course_x)
  end
  
  test "faculty cannot manage anthing on her course if not faculty" do
    @fxAbility = Ability.new(@account, @user, nil, @course_x)
    assert @fxAbility.cannot?(:manage, @course_x)
  end
  
  test "faculty cannot manage anything on courses other than her own" do
    @fxAbility = Ability.new(@account, @instructor_x, nil, @course_y)
    assert @fxAbility.cannot?(:manage, @course_y)
  end
  
  test "faculty can create a class on her course" do
    assert @fyAbility.can?(:create, @klass_y)
  end

  test "faculty can view a class of her course" do
    @fyAbility = Ability.new(@account, @instructor_y, @instructor_y.self_student, @course_y, @klass)
    assert @fyAbility.can?(:show, @klass)
  end

  # Student
  test "student can enroll in klasses" do
  	@ability = Ability.new(@account, @student, @student.self_student, @course_x, @klass_x)
    assert @ability.cannot?(:enroll, @klass_x)
  end

  test "student cannot drop a klass that she's not enrolled in" do
  	@ability = Ability.new(@account, @student, @student.self_student, @course_x, @klass_x)
    assert @ability.cannot?(:drop, @klass_x)
  end

  # Guest
  test "guest can visit front page" do
    assert Ability.new(@account, @guest).can?(:front, User)
  end

  test "guestcan visit blogs page" do
    assert Ability.new(@account, @guest).can?(:blogs, Page)
  end

end