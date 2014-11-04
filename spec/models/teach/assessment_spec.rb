require 'spec_helper' 

describe Assessment do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(build(:assessment)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:assessment, name: nil)).to_not be_valid
    end
    
    it "is valid without about" do
      expect(build(:assessment, about: nil)).to be_valid
    end
    
    it "is invalid if its name is more than 100 character" do
      expect(build(:assessment, name: 
        '01234567890123456789012345678901234567890123456789' +
        '01234567890123456789012345678901234567890123456789 ')).to_not be_valid
    end
    
    it "is invalid if allowed_attempts <= 0" do
      expect(build(:assessment, allowed_attempts: 0)).to_not be_valid
    end
    
    it "is invalid if penalty is not numeric" do
      expect(build(:assessment, penalty: 'x')).to_not be_valid
    end
    
    it "is invalid without a from_datetime" do
      expect(build(:assessment, from_datetime: nil)).to_not be_valid
    end
    
    it "is invalid without a to_datetime" do
      expect(build(:assessment, to_datetime: nil)).to be_valid
    end
    
    it "is invalid if to_datetime is before from_datetime" do
      expect(build(:assessment, to_datetime: Time.zone.now - 2.days)).to_not be_valid
    end
    
    it "is invalid if either invideo_id or invideo_at is blank" do
      expect(build(:assessment, invideo_id: 1, invideo_at: nil)).to_not be_valid
      expect(build(:assessment, invideo_id: nil, invideo_at: 100)).to_not be_valid
    end
    
    it "is invalid if droppable_attempts < 0" do
      expect(build(:assessment, droppable_attempts: -1)).to_not be_valid
    end
    
    it "is invalid if allowed_attempts <= 0" do
      expect(build(:assessment, allowed_attempts: 0)).to_not be_valid
    end
    
    it "is invalid if droppable_attempts < 0" do
      expect(build(:assessment, droppable_attempts: -1)).to_not be_valid
    end
    
    it "is invalid if penalty < 0" do
      expect(build(:assessment, penalty: -1)).to_not be_valid
    end
      
  end 
end