require 'spec_helper'

describe Update do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:update)).to be_valid
    end

    it "is invalid without a subject if www" do
      expect(build(:update, subject: nil, www: true)).to_not be_valid
    end
    
    it "is invalid without a subject if email" do
      expect(build(:update, subject: nil, email: true, www: false)).to_not be_valid
    end
    
    it "is invalid without an body" do
      expect(build(:update, body: nil)).to_not be_valid
    end
    
    it "is invalid without to" do
      expect(build(:update, to: nil)).to_not be_valid
    end
  end 
end
