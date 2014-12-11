require 'spec_helper' 

describe Course do 
  describe 'Validations' do
    it "has a valid factory." do 
      expect(create(:course)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:course, name: nil)).to_not be_valid
    end
    
    it "is invalid without an about" do
      expect(build(:course, about: nil)).to_not be_valid
    end
    
    it "is invalid without weeks" do
      expect(build(:course, weeks: nil)).to_not be_valid
    end
    
    it "is invalid with 0 weeks" do
      expect(build(:course, weeks: 0)).to_not be_valid
    end
    
    it "is invalid with < 0 weeks" do
      expect(build(:course, weeks: -1)).to_not be_valid
    end
    
    it "is invalid without workload" do
      expect(build(:course, workload: nil)).to_not be_valid
    end
    
    it "is invalid with 0 workload" do
      expect(build(:course, workload: 0)).to_not be_valid
    end    
    
    it "is invalid with < 0 workload" do
      expect(build(:course, workload: -1)).to_not be_valid
    end
    
    it "is invalid without a locale" do
      expect(build(:course, locale: nil)).to_not be_valid
    end
  end 
  
  describe "Methods and scopes" do
    
    it "has its initial class" do
      expect(create(:course).klasses.to_a.count).to eq 1
    end
    
    it "has its settings/configuration" do
      expect(create(:course).config.present?).to be(true)
    end

    it "has no non-syllabus pages when created" do
      expect(create(:course).non_syllabus_pages.count).to eq 0
    end
    
    it "has its pages" do
      expect(create(:course).pages.to_a.count).to_not eq 0
    end
    
        
    it "has its grade distribution info" do
      course = create(:course)
      
      expect(GradeDistribution.where(:course_id => course.id).to_a.count).to_not eq 0
    end
    
    it "has a syllabus" do
      expect([create(:course).syllabus].count).to eq 1
    end
    
    it "has no unapproved klasses if freshly created" do
      expect(create(:course).unapproved_klasses.count).to eq 1
    end
    
    
    it "can have a poster" do
      course = create(:course)
      m = create(:material, :kind => 'image', :medium => create(:image_medium))
      m.tag_list.add('poster')
      course.materials << m
      
      expect(course.poster).to eq(course.materials.first)
    end
    
    it "can have a promo video" do
      course = create(:course)
      m = create(:material, :kind => 'video', :medium => create(:video_medium))
      m.tag_list.add('promo')
      course.materials << m
      
      expect(course.video).to eq(course.materials.first)
    end
    
    it "can have books" do
      course = create(:course)
      create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
      create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
      create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
      
      expect(course.books.count).to eq 3
    end
  end
end



