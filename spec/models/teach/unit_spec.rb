require 'spec_helper' 

describe Unit do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:unit)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:unit, name: nil)).to_not be_valid
    end
    
    it "is invalid without an about" do
      expect(build(:unit, about: nil)).to_not be_valid
    end
    
    it "is invalid without on_date" do
      expect(build(:unit, on_date: nil)).to_not be_valid
    end
    
    it "is valid with  on_date = today" do
      expect(build(:unit, on_date: Time.zone.today )).to be_valid
    end
    
    it "is invalid with on_date < today " do
      expect(build(:unit, on_date: Time.zone.today - 1)).to_not be_valid
    end
    
    it "is valid without for_days" do
      expect(build(:unit, for_days: nil)).to be_valid
    end
    
    it "is invalid with 0 for_days" do
      expect(build(:unit, for_days: 0)).to_not be_valid
    end    
    
    it "is invalid with < 0 for_days" do
      expect(build(:unit, for_days: -1)).to_not be_valid
    end
  end 
  
  describe "Methods and scopes" do    
    it "lists open units" do
      klass = create(:klass)
      course = klass.course
      create(:unit, course: course, on_date: Time.zone.today)
      create(:unit, course: course, on_date: Time.zone.today + 7)
      create(:unit, course: course, on_date: Time.zone.today + 14)
      
      student = create(:user).students.where(relationship: 'self').first

      enrollment = klass.enrollments.new(:student_id => student.id, :active => true)
      enrollment.accepted_or_declined_at = Time.zone.now
      enrollment.save!

      expect(Unit.open(klass, student).to_a.count).to eq 1
    end
    
    it "checks if unit is open" do
      I18n.locale = :en
      klass = create(:klass)
      course = klass.course
      u = create(:unit, course: course, on_date: Time.zone.today )
      v = create(:unit, course: course, on_date: Time.zone.today  + 7)
      w = create(:unit, course: course, on_date: Time.zone.today + 14 )
      
      student = create(:user).students.where(relationship: 'self').first
      #Thread.current[:current_user] = student
      enrollment = klass.enrollments.new(:student_id => student.id, :active => true)
      enrollment.accepted_or_declined_at = Time.zone.now
      enrollment.save!
      
      expect(u.open?(klass) && !v.open?(klass) && !w.open?(klass)).to be(true)
    end
  end
end
