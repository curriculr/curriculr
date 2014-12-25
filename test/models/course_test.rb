require 'test_helper'

class CourseTest < ActiveSupport::TestCase
	def setup
		@course = courses(:eng101)
	end

	test "with valid fixtures" do
    assert courses(:eng101).valid?
    assert courses(:stat101).valid?
  end

  test "invalid without a name" do
  	@course.name = nil
  	assert_not @course.valid?
  end
  
  test "invalid without an about" do
    @course.about = nil
  	assert_not @course.valid?
  end
  
  test "invalid without weeks or with <= 0 weeks" do
    @course.weeks = nil
  	assert_not @course.valid?

  	@course.weeks = 0
  	assert_not @course.valid?

  	@course.weeks = -1
  	assert_not @course.valid?
  end
  
  test "invalid without workload or <=0 workload" do
    @course.workload = nil
  	assert_not @course.valid?

  	@course.workload = 0
  	assert_not @course.valid?

  	@course.workload = -1
  	assert_not @course.valid?
  end
  
  test "invalid without a locale" do
  	@course.locale = nil
  	assert_not @course.valid?
  end
  
  test "has its initial class" do
    assert_equal 1, courses(:stat101).klasses.to_a.count
  end
  
  test "has its settings/config" do
  	assert @course.config.present?
  end
  
  test "has its syllabus and/or pages" do
    assert @course.syllabus.present?
		assert_equal 3, @course.pages.count
    assert_equal 2, @course.non_syllabus_pages.count
  end
  
  test "has grade distribution" do
    GradeDistribution.redistribute(@course, @course.config)
    
    assert_not_equal 0, GradeDistribution.where(:course_id => @course.id).to_a.count
  end
  
  # it "can have a poster" do
  #   course = create(:course)
  #   m = create(:material, :kind => 'image', :medium => create(:image_medium))
  #   m.tag_list.add('poster')
  #   course.materials << m
    
  #   expect(course.poster).to eq(course.materials.first)
  # end
  
  # it "can have a promo video" do
  #   course = create(:course)
  #   m = create(:material, :kind => 'video', :medium => create(:video_medium))
  #   m.tag_list.add('promo')
  #   course.materials << m
    
  #   expect(course.video).to eq(course.materials.first)
  # end
  
  # it "can have books" do
  #   course = create(:course)
  #   create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
  #   create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
  #   create(:material, :owner => course, :kind => 'document', :medium => create(:document_medium), tag_list: [:books])
    
  #   expect(course.books.count).to eq 3
  # end
end
