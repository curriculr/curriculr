require 'spec_helper' 

describe Forum do 
  describe 'validations' do
    it "has a valid factory." do 
      expect(create(:forum)).to be_valid
    end

    it "is invalid without name" do
      expect(build(:forum, name: nil)).to_not be_valid
    end
    
    it "is invalid without an about" do
      expect(build(:forum, about: nil)).to_not be_valid
    end
  end 
end

describe Topic do 
  describe 'validations' do
    it "has a valid factory." do 
      expect(create(:topic)).to be_valid
    end

    it "is invalid without name" do
      expect(build(:topic, name: nil)).to_not be_valid
    end
    
    it "is invalid without an about" do
      expect(build(:topic, about: nil)).to_not be_valid
    end
  end 
end

describe Post do 
  describe 'validations' do 
    it "has a valid factory." do 
      expect(create(:post)).to be_valid
    end
   
    it "is invalid without an about" do
      expect(build(:post, about: nil)).to_not be_valid
    end
  end 
end