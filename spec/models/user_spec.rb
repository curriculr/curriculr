require 'spec_helper' 

describe User do   
   describe 'validation' do
    it "has a valid factory." do 
      expect(create(:user)).to be_valid
    end

    it "is invalid without an email." do
      expect(build(:user, email: nil)).to_not be_valid
    end

    it "is invalid without a name." do
      expect(build(:user, name: nil)).to_not be_valid
    end

    it "has a profile and a corresponding student" do
      u = create(:user)
      expect(u.profile.blank?).to(be(false)) && expect(u.students.blank?).to(be(false))
    end
    

    it "is invalid when password is < 8 characters long." do
      expect(build(:user, password: 'test123')).to_not be_valid
    end

    it "is invalid with password does not match confirmation." do
      expect(build(:user, password: 'test1234', password_confirmation: 'test4321')).to_not be_valid
    end 
  end
end