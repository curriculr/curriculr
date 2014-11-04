require 'spec_helper' 

describe Klass do 
  describe 'Validations' do  
    it "has a valid factory." do 
      expect(build(:klass)).to be_valid
    end

    it "is valid without an about" do
      expect(build(:klass, about: nil)).to be_valid
    end
    
    it "is invalid without begins_on" do
      expect(build(:klass, begins_on: nil)).to_not be_valid
    end
    
    it "is valid without ends_on" do
      expect(build(:klass, ends_on: nil)).to be_valid
    end
    
    it "is invalid when begins_on is before today" do
      expect(build(:klass, begins_on: 2.days.ago)).to_not be_valid
    end
    
    it "is invalid when ends_on is before begins_on" do
      expect(build(:klass, begins_on: 2.days.ago, ends_on: 3.days.ago)).to_not be_valid
    end
  end 
  
  describe "Methods and scopes" do

  end
end
