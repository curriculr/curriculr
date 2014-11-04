require 'spec_helper' 
require "cancan/matchers"

describe Ability do 
  before :each do
    @admin = create(:admin)

    @course_x = create(:course)
    @instructor_x = @course_x.originator
    
    @course_y = create(:course)
    @instructor_y = @course_y.originator
    
    @aAbility = Ability.new($account, @admin)
    @fxAbility = Ability.new($account, @instructor_x, @instructor_x.students.where(relationship: 'self').first, @course_x)
    @fyAbility = Ability.new($account, @instructor_y, @instructor_y.students.where(relationship: 'self').first, @course_y)

    @student = create(:user)
    @guest = nil
  end

  context 'admins' do
    it 'can do anything' do
      expect(@aAbility).to be_able_to(:manage, :all)
    end
  end
  
  context 'faculty' do
    it "can manage everything on her course" do
      expect(@fxAbility).to be_able_to(:manage, @course_x)
    end
    
    it "cannot manage anthing on her course if not faculty" do
      @fxAbility = Ability.new($account, @user, nil, @course_x)
      expect(@fxAbility).to_not be_able_to(:manage, @course_x)
    end
    
    it "cannot manage anything on courses other than her own" do
      @fxAbility = Ability.new($account, @instructor_x, nil, @course_y)
      expect(@fxAbility).to_not be_able_to(:manage, @course_y)
    end
    
    it "can create a class on her course" do
      klass = build(:klass, course: @course_y)
      expect(@fyAbility).to be_able_to(:create, klass)
    end

    it "can view a class of her course" do
      @fyAbility = Ability.new($account, @instructor_y, @instructor_y.students.where(relationship: 'self').first, @course_y, @klass)
      expect(@fyAbility).to be_able_to(:show, @klass)
    end
  end
  
  context 'student' do
    before :each do
      @klass = create(:klass, course: @course_x)
      @ability = Ability.new($account, @student, @student.students.where(relationship: 'self').first, @course_x, @klass)
    end

    it "can enroll in klasses" do
      expect(@ability).to be_able_to(:enroll, @klass)
    end

    it "cannot drop a klass that she's not enrolled in" do
      expect(@ability).to_not be_able_to(:drop, @klass)
    end
  end
  
  context 'guest' do
    before :each do
      @ability = Ability.new($account, @guest)
    end

    it "can visit front page" do
      expect(@ability).to be_able_to(:front, User)
    end

    it "can visit blogs page" do
      expect(@ability).to be_able_to(:blogs, Page)
    end
  end

end