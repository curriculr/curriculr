require 'spec_helper' 

describe Enrollment do   
  describe "Methods and scopes" do
    before :each do
      @course = create(:course)
      @klass = @course.klasses.first
      @klass.update(:approved => true)
      @unit = create(:unit, course: @course, on_date: Time.zone.today)

      l = create(:lecture, unit: @unit, on_date: Time.zone.today)
      l.materials << create(:material, :kind => 'video', :medium => create(:video_medium))
      n = create(:lecture, unit: @unit, on_date: Time.zone.today)
      n.materials << create(:material, :kind => 'video', :medium => create(:video_medium))
      o = create(:lecture, unit: @unit, on_date: Time.zone.today + 7)
      o.materials << create(:material, :kind => 'video', :medium => create(:video_medium))

      @student = create(:user).students.where(relationship: 'self').first
      @enrollment = KlassEnrollment.enroll(@klass, @student)
    end

    it "increases klass total enrollments when created" do
      expect(@klass.enrollments.count).to eq (1)
      expect(@klass.enrollments.where(active: true).count).to eq (1)
    end

    it "decreases klass active enrollments when dropped" do
      expect(@klass.enrollments.count).to eq (1)
      expect(@klass.enrollments.where(active: true).count).to eq (1)
      KlassEnrollment.drop(@enrollment)
      expect(@klass.enrollments.count).to eq (1)
      expect(@klass.enrollments.where(active: true).count).to eq (0)
    end
  end
end
