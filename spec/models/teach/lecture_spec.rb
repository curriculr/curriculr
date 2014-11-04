require 'spec_helper' 

describe Lecture do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:lecture)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:lecture, name: nil)).to_not be_valid
    end
    
    it "is invalid without an about" do
      expect(build(:lecture, about: nil)).to_not be_valid
    end
    
    it "is invalid without on_date" do
      expect(build(:lecture, on_date: nil)).to_not be_valid
    end
    
    it "is invalid with on_date = today" do
      expect(build(:lecture, on_date: Time.zone.today)).to be_valid
    end
    
    it "is invalid with on_date < today" do
      expect(build(:lecture, on_date: Time.zone.today - 1)).to_not be_valid
    end
    
    it "is valid without for_days" do
      expect(build(:lecture, for_days: nil)).to be_valid
    end
    
    it "is invalid with 0 for_days" do
      expect(build(:lecture, for_days: 0)).to_not be_valid
    end    
    
    it "is invalid with < 0 for_days" do
      expect(build(:lecture, for_days: -1)).to_not be_valid
    end
  end
  
  describe "Methods and scopes for students" do
    before :each do
      @course = create(:course)
      @klass = @course.klasses.first
      @klass.update(:approved => true)
      @unit = create(:unit, course: @course, on_date: Time.zone.today)

      l = create(:lecture, unit: @unit, on_date: Time.zone.today)
      l.materials << create(:material, :kind => 'video', :medium => create(:video_medium))
      n = create(:lecture, unit: @unit, on_date: Time.zone.today)
      n.materials << create(:material, :kind => 'video', :medium => create(:video_medium))
      o = create(:lecture, unit: @unit, on_date: Time.zone.today + 7)
      o.materials << create(:material, :kind => 'video', :medium => create(:video_medium))

      @student = create(:user).students.where(relationship: 'self').first
      KlassEnrollment.enroll(@klass, @student)
    end
    
    it "lists lectures that are open for students" do
      expect(Lecture.open_4_students(@klass, @unit, @student).to_a.count).to eq 2
    end
    
    it "checks attendance" do
      expect(Lecture.attendance(@klass, @student).to_a.count).to eq 2
    end
  end 
end