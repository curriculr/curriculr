require 'spec_helper' 

describe Medium do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:video_medium)).to be_valid
      expect(create(:audio_medium)).to be_valid
      expect(create(:image_medium)).to be_valid
      expect(create(:document_medium)).to be_valid
      expect(create(:other_medium)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:medium, name: nil)).to_not be_valid
    end
    
    it "is invalid without a kind" do
      expect(build(:video_medium, kind: nil)).to_not be_valid
    end    
    
    it "is invalid without a path and a url" do
      expect(build(:medium, path: nil, is_a_link: '1' , url: nil)).to_not be_valid
    end
    
    it "is valid without a path but with a url" do
      expect(build(:document_medium, path: nil, url: 'http://www.google.com')).to be_valid
    end
  end 
  
  describe "Methods and scopes" do
    it "has a url" do
      expect(create(:video_medium).at_url).to_not be_empty
    end
  end
end

describe Material do 
  describe 'Factories' do
    it "has a valid factory." do 
      expect(create(:material)).to be_valid
    end
    
    it "has a valid factory for video material." do 
      expect(create(:material, :medium => create(:video_medium))).to be_valid
    end
    
    it "has a valid factory for audio material." do 
      expect(create(:material, :medium => create(:audio_medium))).to be_valid
    end
    
    it "has a valid factory for image material." do 
      expect(create(:material, :medium => create(:image_medium))).to be_valid
    end
    
    it "has a valid factory for document material." do 
      expect(create(:material, :medium => create(:document_medium))).to be_valid
    end
    
    it "has a valid factory for other material." do 
      expect(create(:material, :medium => create(:other_medium))).to be_valid
    end
  end
  
  describe 'Validations' do
    it "is invalid without a kind" do
      m = build(:material)
      m.kind = nil
      expect(m).to_not be_valid
    end
  end 
  
  describe "Methods and scopes" do
    it "has a url" do
      expect(create(:material, :medium => create(:image_medium)).at_url).to_not be_empty
    end
  end
end