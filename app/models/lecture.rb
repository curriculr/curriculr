class Lecture < ActiveRecord::Base
  include WithMaterials
  include Actionable

  acts_as_taggable_on :tags

  belongs_to :unit, :counter_cache => true
	has_many :assessments, :dependent => :destroy
  has_many :questions, :dependent => :destroy
  has_many :pages, :dependent => :destroy, :as => :owner
  has_many :updates, :dependent => :destroy
  has_many :lecture_discussions, :dependent => :destroy

	# Validation Rules
	validates :name, :presence => true, :length => {:maximum => 100 }
	validates :on_date, :based_on, :about, :presence => true
  validates :for_days, :numericality => {:only_integer => true, :greater_than => 0, :allow_nil => true }
  validates :points, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
	validates :order, :numericality => {:only_integer => true }
  validate :proper_on_date

  def proper_on_date
    if on_date.present? && on_date < based_on
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
    if forum.present?
      LectureDiscussion.where(klass_id: klass.id,
        forum_id: forum.id, lecture_id: self.id).first_or_initialize
    end
  end

  def contents(published_only, staff_or_enrolled)
    data = []
    data += self.materials_of_kind([:video, :audio, :image, :document, :other]).
      tagged_with("poster", :exclude => true).to_a
    data += self.questions.where(:include_in_lecture => true).to_a if staff_or_enrolled

    if published_only
      data += self.pages.where(:published => true).to_a
      data += self.assessments.where(:ready => true).where("invideo_id is null").to_a if staff_or_enrolled
    else
      data += self.pages.to_a
      data += self.assessments.to_a if staff_or_enrolled
    end

    data.sort! { |x,y| x.order <=> y.order}

    data
  end

  def log_attendance(klass, student, item, data = nil, count = 0.0)
    activity = case item
    when Material
      item.log_activity('opened', klass, student, self)
    when Page
      item.log_activity('visited', klass, student, self)
    when Question
      data ? item.log_activity('attempted', klass, student, self, 0, false, data) : nil
    when Assessment
      item.log_activity('attempted', klass, student, self)
    else
      nil
    end

    if activity && activity.times == 1
      a = self.activities.where(:action => 'attended', :klass => klass, :student => student).first_or_initialize

      points = a.new_record? ? self.points : (a.data ? a.data[:points] : 0.0)
      count = a.new_record? ? count : (count == 0.0 ? (a.data ? a.data[:count] : 0.0) : count)

      self.log_activity('attended', klass, student, nil, (points.to_f / count.to_f).round(2) ,
        true, { points: points, count: count })
    end
  end

  def pagers(klass, student)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      date_clause = "(DATE :base_date + (lectures.on_date - lectures.based_on) + lectures.for_days)"
    else
      date_clause = "adddate(DATE(:base_date), (lectures.on_date - lectures.based_on) + lectures.for_days)"
    end

    lectures = Lecture.joins(:unit => {:course => :klasses}).with_content_4_students.
      order('units.order, lectures.order').
      select('courses.id as course, units.id as unit, lectures.id as lecture, units.order, lectures.order').
      where("courses.id = :course_id and klasses.id = :klass_id and
             (lectures.on_date - lectures.based_on) <= (DATE(:today) - DATE(:base_date)) and
             (lectures.for_days is null or #{date_clause} > :today)",
             :course_id => klass.course.id,
             :klass_id => klass.id,
             :base_date => klass.begin_date(student),
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

  # default_scope -> {
  #   order 'lectures.order'
  # }

	scope :attendance, ->(klass, student) {
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      unit_date_clause = "(DATE :base_date + (units.on_date - units.based_on))"
      lecture_date_clause =  "(DATE :base_date + (lectures.on_date - lectures.based_on) - 1)"
    else
      unit_date_clause = "adddate(DATE(:base_date), (units.on_date - units.based_on))"
      lecture_date_clause =  "adddate(DATE(:base_date), (lectures.on_date - lectures.based_on) - 1)"
    end

    joins(:unit => {:course => :klasses}).
    joins("left outer join activities on activities.klass_id = klasses.id and
             activities.actionable_type = 'Lecture' and activities.actionable_id = lectures.id and
             activities.student_id = #{student.id}").
    where("klasses.id = #{klass.id} and
      #{unit_date_clause} <= :as_of and #{lecture_date_clause} <= :as_of ", :as_of => Time.zone.today,
      :base_date => klass.begin_date(student)).
    group('units.id, lectures.id, activities.id').
    select('units.name as u_name, lectures.name as name').
    select('coalesce(activities.times, 0) as attended').
    select('units.order, lectures.order').
    order('units.order, lectures.order')
  }

  #
  scope :with_content_4_students, ->  {
    where(%(
      exists (
        SELECT * FROM materials
        WHERE materials.owner_type = 'Lecture' AND materials.owner_id = 1 AND
          not exists (
            SELECT taggings.taggable_id FROM taggings, tags
            WHERE taggings.tag_id = tags.id AND tags.name = 'poster' AND
              taggings.taggable_id = materials.id AND taggings.taggable_type = 'Material'
          )
      ) OR exists (
        SELECT pages.* FROM pages
        WHERE pages.owner_type = 'Lecture' AND pages.owner_id = lectures.id AND
          pages.published = TRUE
      ) OR exists (
        SELECT questions.* FROM questions
        WHERE questions.lecture_id = lectures.id AND questions.include_in_lecture = TRUE
      ) OR exists (
        SELECT assessments.* FROM assessments
        WHERE assessments.lecture_id = lectures.id AND assessments.ready = TRUE
      )
    ))
  }

  scope :open_4_students, ->(klass, unit, student, include_everything = false) {
    q = joins(:unit => {:course => :klasses}).
    joins(%(left outer join (
      SELECT activities.*
      FROM activities WHERE
        activities.actionable_type = 'Lecture' AND
        activities.student_id = #{student && klass.enrolled?(student) ? student.id : -1} AND
        activities.klass_id = #{klass.id} AND
        activities.action = 'attended') activity on lectures.id = activity.actionable_id)).
    # joins(%(left outer join (
    #   SELECT activities.context_id, count(activities.id) as count
    #   FROM activities WHERE
    #     activities.klass_id = #{klass.id} AND
    #     activities.student_id = #{student.id} AND
    #     activities.context_type = 'Lecture'
    #   GROUP BY activities.context_id
    #   ) attendance on lectures.id = attendance.context_id)).
    with_content_4_students

    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      q = q.where("
        (klasses.ends_on is null or (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE) or
        (klasses.ends_on > :today and
        (lectures.on_date - lectures.based_on) <= (DATE(:today) - DATE :base_date) and
        (lectures.for_days is null or
          (DATE :base_date + (lectures.on_date - lectures.based_on) + lectures.for_days) > :today))) and
        courses.id = :course_id and units.id = :unit_id and klasses.id = :klass_id",
        :course_id => klass.course.id, :unit_id => unit.id, :klass_id => klass.id, :today => Time.zone.now,
        :base_date => klass.begin_date(student))
    else
      q = q.where("
        (klasses.ends_on is null or (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE) or
        (klasses.ends_on > :today and
        (lectures.on_date - lectures.based_on) <= (DATE(:today) - DATE(:base_date)) and
        (lectures.for_days is null or
          adddate(DATE(:base_date), (lectures.on_date - lectures.based_on) + lectures.for_days) > :today))) and
        courses.id = :course_id and units.id = :unit_id and klasses.id = :klass_id",
        :course_id => klass.course.id, :unit_id => unit.id, :klass_id => klass.id, :today => Time.zone.now,
        :base_date => klass.begin_date(student))
    end

    unless include_everything || klass.enrolled?(student) || (student && KlassEnrollment.staff?(student.user, klass))
      q = q.where('klasses.previewed = TRUE and units.previewed = TRUE and lectures.previewed = TRUE')
    end

    q.select(%(
      lectures.order, lectures.id, lectures.name, lectures.about,
      lectures.based_on, lectures.on_date, lectures.for_days,
      coalesce(activity.times, 0) as attended, activity.data as attendance_data,
      lectures.previewed
    )).order("lectures.order").distinct
  }

  def open?(base_date)
    today = Time.zone.today
    on_day = (self.on_date - self.based_on).to_i
    on_day <= (today - base_date).to_i && (self.for_days.blank? || (base_date + on_day + self.for_days) > today)
  end

  def begins_on(base_date)
    (base_date + (self.on_date - self.based_on).to_i)
  end

  def ends_on(base_date)
    self.for_days.present? ? (begins_on(base_date) + self.for_days) : nil
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

  # before_destroy do |lecture|
  #   discussions = LectureDiscussion.where(lecture_id: lecture.id)
  #   #discussions.transaction do
  #     discussions.each do |discussion|
  #       discussion.topic.destroy
  #       discussion.destroy
  #     end
  #     #end
  # end

  def self.generate_discussion_topics(klasses)
    klasses.each do |klass|
      forum = Forum.unscoped.joins(:klass).
        where('klasses.course_id = :course_id and lecture_comments = TRUE and klasses.id = :klass_id',
        :course_id => klass.course_id, :klass_id => klass.id).first
      Lecture.joins(:unit).where('units.course_id = :course_id', :course_id => klass.course_id).each do |lecture|
        forum.transaction do
          discussion = LectureDiscussion.where(klass_id: klass.id,
            forum_id: forum.id, lecture_id: lecture.id).first_or_initialize
          if discussion.new_record? || discussion.topic.blank?
            discussion.topic = forum.topics.create(:name => lecture.name, :about => lecture.about,
              :author => lecture.unit.course.originator)

            discussion.save
          end
        end
      end
    end
  end

end
