require 'spec_helper' 

describe Question do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:simple_question)).to be_valid
      expect(create(:fill_question)).to be_valid
      expect(create(:pick_2_fill_question)).to be_valid
      expect(create(:pick_one_question)).to be_valid
      expect(create(:pick_many_question)).to be_valid
      expect(create(:match_question)).to be_valid
      expect(create(:underline_question)).to be_valid
      expect(create(:sort_question)).to be_valid
    end

    it "is invalid without an question" do
      expect(build(:simple_question, question: nil)).to_not be_valid
    end
    
    it "is invalid without a kind" do
      expect(build(:question, kind: nil)).to_not be_valid
    end
    
    it "is valid without a hint" do
      expect(build(:fill_question, hint: nil)).to be_valid
    end
    
    it "is valid without an explanation" do
      expect(build(:pick_2_fill_question, explanation: nil)).to be_valid
    end
    
    it "is invalid if it's a simple and answer is nil" do
      expect(build(:question, :kind => 'simple')).to_not be_valid
    end
    
    it "is invalid if it's a simple with more that one answer" do
      question = build(:simple_question)
      question.options << Option.new(:answer => Faker::Lorem.word)
      expect(question).to_not be_valid
    end
    
    it "is invalid if it's a fill and has no choice" do
      expect(build(:question, :kind => 'fill')).to_not be_valid
    end
    
    it "is invalid if it's a pick_2_fill and has no choice" do
      expect(build(:question, :kind => 'pick_2_fill')).to_not be_valid
    end
    
    it "is invalid if it's a pick_one and has no choice" do
      expect(build(:question, :kind => 'pick_one')).to_not be_valid
    end
    
    it "is invalid if it's a pick_many and has no choice" do
      expect(build(:question, :kind => 'pick_many')).to_not be_valid
    end
    
    it "is invalid if it's a match and has no choice" do
      expect(build(:question, :kind => 'match')).to_not be_valid
    end
    
    it "is invalid if it's a underline and has no choice" do
      expect(build(:question, :kind => 'underline')).to_not be_valid
    end
    
    it "is invalid if it's a sort and has no choice" do
      expect(build(:question, :kind => 'sort')).to_not be_valid
    end
  end 
end