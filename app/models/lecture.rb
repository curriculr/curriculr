class Lecture < ActiveRecord::Base
  include WithMaterials
  include Actionable
  
  belongs_to :unit, :counter_cache => true
	has_many :assessments, :dependent => :destroy
  has_many :pages, :dependent => :destroy, :as => :owner
  
	# Validation Rules
	validates :name, :presence => true, :length => {:maximum => 100 }
	validates :on_date, :based_on, :about, :presence => true
  validates :for_days, :numericality => {:only_integer => true, :greater_than => 0, :allow_nil => true }
  validates :points, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
	validates :order, :numericality => {:only_integer => true }
  validate :proper_on_date

  def proper_on_date
    if on_date.present? and on_date < based_on
      errors.add :on_date, :must_be_after_date, :date => based_on
    end
  end
  
  def course
    unit.course
  end
  
  def poster
    self.materials.joins(:taggings).joins(:tags).where("materials.kind = 'image' and tags.name = 'poster'").first
  end
  
  def discussion(klass)
    forum = Forum.unscoped.find_by(:klass_id => klass.id, :lecture_comments => true)
    
    LectureDiscussion.where(klass_id: klass.id, 
      forum_id: forum.id, lecture_id: self.id).first_or_initialize  
  end
  
  def pagers(klass, student)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      date_clause = "(DATE :begins_on + (lectures.on_date - lectures.based_on) + lectures.for_days)"
    else
      date_clause = "adddate(DATE(:begins_on), (lectures.on_date - lectures.based_on) + lectures.for_days)"
    end

    lectures = Course.joins(:klasses).joins(:units => :lectures).order('units.order, lectures.order').
      select('courses.id as course, units.id as unit, lectures.id as lecture').
      where("courses.id = :course_id and klasses.id = :klass_id and
             (lectures.on_date - lectures.based_on) <= (DATE(:today) - DATE(:begins_on)) and 
             (lectures.for_days is null or #{date_clause} > :today)", 
             :course_id => klass.course.id,
             :klass_id => klass.id,
             :begins_on => klass.begins_on,
             :today => Time.zone.now)

    unless klass.enrolled?(student) || (student && KlassEnrollment.staff?(student.user, klass))
      lectures = lectures.where('klasses.previewed = TRUE and units.previewed = TRUE and lectures.previewed = TRUE') 
    end
      
    lectures = lectures.to_a
    
    index = lectures.find_index { |l| l[:lecture] == self.id }
    count = lectures.count
    if count <= 1
      [ nil, nil ]
    elsif index == 0
      [ nil, lectures[index + 1] ]
    elsif index == (count - 1)
      [ lectures[index - 1], nil ]
    else
      [ lectures[index - 1], lectures[index + 1] ]
    end
  end
	  
  default_scope -> { 
    order 'lectures.order'
  }
  
	scope :attendance, ->(klass, student) {
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      unit_date_clause = "(klasses.begins_on + (units.on_date - units.based_on))"
      lecture_date_clause =  "(klasses.begins_on + (lectures.on_date - lectures.based_on) - 1)"
    else
      unit_date_clause = "adddate(klasses.begins_on, (units.on_date - units.based_on))"
      lecture_date_clause =  "adddate(klasses.begins_on, (lectures.on_date - lectures.based_on) - 1)"
    end

    joins(:unit => {:course => :klasses}).
    joins("left outer join activities on activities.klass_id = klasses.id and 
             activities.actionable_type = 'Lecture' and activities.actionable_id = lectures.id and
             activities.student_id = #{student.id}").
    where("klasses.id = #{klass.id} and
      #{unit_date_clause} <= :as_of and #{lecture_date_clause} <= :as_of ", :as_of => Time.zone.today).
    group('units.id, lectures.id, activities.id').
    select('units.name as u_name, lectures.name as name').
    select('coalesce(activities.times, 0) as attended').
    select('units.order, lectures.order').
    order('units.order, lectures.order')
  }
  
  #MYSQL
  scope :open_4_students, ->(klass, unit, student) {
    q = joins(:unit => {:course => :klasses}).
    joins(%(left outer join (
      SELECT materials.* FROM materials, taggings, tags WHERE 
        taggings.taggable_id = materials.id AND taggings.taggable_type = 'Material' AND
        tags.id = taggings.tag_id AND 
        materials.owner_type = 'Lecture' AND 
        tags.name = 'main' AND
        materials.kind = 'video') video on lectures.id = video.owner_id)).
    joins(%(left outer join (
      SELECT materials.* FROM materials, taggings, tags WHERE 
        taggings.taggable_id = materials.id AND taggings.taggable_type = 'Material' AND
        tags.id = taggings.tag_id AND 
        materials.owner_type = 'Lecture' AND 
        tags.name = 'main' AND
        materials.kind = 'audio') audio on lectures.id = audio.owner_id)).
    joins(%(left outer join (
      SELECT materials.* FROM materials, taggings, tags WHERE 
        taggings.taggable_id = materials.id AND taggings.taggable_type = 'Material' AND
        tags.id = taggings.tag_id AND 
        materials.owner_type = 'Lecture' AND 
        tags.name = 'main' AND
        materials.kind = 'slides') slides on lectures.id = slides.owner_id)).
    joins(%(left outer join (
      SELECT pages.* FROM pages, taggings, tags WHERE 
        taggings.taggable_id = pages.id AND taggings.taggable_type = 'Page' AND
        tags.id = taggings.tag_id AND 
        pages.owner_type = 'Lecture' AND 
        tags.name = 'text') text on lectures.id = text.owner_id)).
    joins(%(left outer join (
      SELECT activities.* FROM activities WHERE 
        activities.actionable_type = 'Lecture' AND 
        activities.student_id = #{student && klass.enrolled?(student) ? student.id : -1} AND 
        activities.klass_id = #{klass.id} AND 
        activities.action = 'attended') activity on lectures.id = activity.actionable_id))

    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      q = q.where("
        (klasses.ends_on is null or (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE) or
        (klasses.ends_on > :today and
        (lectures.on_date - lectures.based_on) <= (DATE(:today) - klasses.begins_on) and 
        (lectures.for_days is null or 
          (klasses.begins_on + (lectures.on_date - lectures.based_on) + lectures.for_days) > :today))) and
        courses.id = :course_id and units.id = :unit_id and klasses.id = :klass_id and (
          exists (select * from pages where pages.owner_id = lectures.id and pages.owner_type = 'Lecture') or 
          exists (select * from materials where materials.owner_id = lectures.id and materials.owner_type = 'Lecture')
        )", 
        :course_id => klass.course.id, :unit_id => unit.id, :klass_id => klass.id, :today => Time.zone.now)
    else
      q = q.where("
        (klasses.ends_on is null or (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE) or
        (klasses.ends_on > :today and
        (lectures.on_date - lectures.based_on) <= (DATE(:today) - klasses.begins_on) and 
        (lectures.for_days is null or 
          adddate(klasses.begins_on, (lectures.on_date - lectures.based_on) + lectures.for_days) > :today))) and
        courses.id = :course_id and units.id = :unit_id and klasses.id = :klass_id and (
          exists (select * from pages where pages.owner_id = lectures.id and pages.owner_type = 'Lecture') or 
          exists (select * from materials where materials.owner_id = lectures.id and materials.owner_type = 'Lecture')
        )", 
        :course_id => klass.course.id, :unit_id => unit.id, :klass_id => klass.id, :today => Time.zone.now)
    end

    unless klass.enrolled?(student) || (student && KlassEnrollment.staff?(student.user, klass))
      q = q.where('klasses.previewed = TRUE and units.previewed = TRUE and lectures.previewed = TRUE') 
    end
    
    q.select("lectures.order, lectures.id, lectures.name, lectures.about, lectures.based_on, lectures.on_date, lectures.for_days, activity.id as has_been_attended").
      order("lectures.order").distinct
  }

  def open?(klass)
    today = Time.zone.today
    on_day = (self.on_date - self.based_on).to_i
    on_day <= (today - klass.begins_on).to_i and (self.for_days.blank? or (klass.begins_on + on_day + self.for_days) > today)
  end

  # callbacks
  before_create do |lecture|
    lecture.order = (Lecture.where(unit_id: lecture.unit.id).maximum(:order) || 0) + 1
  end
  
  after_create do |lecture|
    forums = Forum.unscoped.joins(:klass => :course).where('courses.id = :course_id and lecture_comments = TRUE', :course_id => lecture.course.id)
    forums.transaction do
      forums.each do |forum|
        discussion = LectureDiscussion.where(klass_id: forum.klass.id, 
          forum_id: forum.id, lecture_id: lecture.id).first_or_initialize
        discussion.topic = forum.topics.create(:name => lecture.name, :about => lecture.about, 
          :author => lecture.unit.course.originator)
      
        discussion.save
      end
    end
  end
  
  after_destroy do |lecture|
    discussions = LectureDiscussion.where(lecture_id: lecture.id)
    discussions.transaction do
      discussions.each do |discussion|
        discussion.topic.destroy
        discussion.destroy
      end
    end
  end
  
  def self.generate_discussion_topics(klasses)
    klasses.each do |klass|
      forum = Forum.unscoped.joins(:klass).
        where('klasses.course_id = :course_id and lecture_comments = TRUE and klasses.id = :klass_id', 
        :course_id => klass.course_id, :klass_id => klass.id).first
      Lecture.joins(:unit).where('units.course_id = :course_id', :course_id => klass.course_id).each do |lecture|
        forum.transaction do
          discussion = LectureDiscussion.where(klass_id: klass.id, 
            forum_id: forum.id, lecture_id: lecture.id).first_or_initialize
          if discussion.new_record? or discussion.topic.blank?
            discussion.topic = forum.topics.create(:name => lecture.name, :about => lecture.about, 
              :author => lecture.unit.course.originator)
  
            discussion.save
          end
        end
      end
    end
  end
  
end
