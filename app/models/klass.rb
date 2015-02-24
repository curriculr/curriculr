class Klass < ActiveRecord::Base
  include Scopeable
  extend FriendlyId
  
  friendly_id :name, use: [ :slugged, :finders ]
  belongs_to :course, :counter_cache => true
  
  has_many :students, :through => :enrollments
  has_many :enrollments, :dependent => :destroy
  has_many :forums, :dependent => :destroy
  has_many :updates, :dependent => :destroy
  
	# Validation Rules
  validates :slug, :presence => true, :length => {:maximum => 100 }
  validates :slug, uniqueness: { :scope => [ :account_id, :course_id ] }
  validates_format_of :slug, :with => /\A[[[:alnum:]]\-_]+\Z/i, :message => :invalid_slug
	validates :begins_on, :presence => true
  validate :has_valid_dates
  
	def has_valid_dates
    errors.add :begins_on, :before_today if new_record? and begins_on and begins_on < Time.zone.today
    errors.add :ends_on, :before_begin_date if begins_on and ends_on and begins_on > ends_on 
	end
  
  PARTS = %w[lectures pages materials assessments discussions reports]
  
  def self.which_are(kind, user)
    (
      case kind
      when 'featured'
        joins(:course).active.featured.looking_ahead.public_only.distinct
      when 'popular'
        joins(:course).active.looking_ahead.public_only.limit(20).order(:active_enrollments).reverse_order.distinct
      when 'open'
        joins(:course).active.open.public_only.distinct
      when 'coming'
        joins(:course).active.coming.public_only.distinct
      when 'enrolled'
        joins(:course).joins(:enrollments).active.looking_ahead.enrolled(user).distinct if user
      when 'taking'
        joins(:course).joins(:enrollments).active.open.enrolled(user).distinct if user
      when 'taken'
        joins(:course).joins(:enrollments).active.closed.enrolled(user).distinct if user
      else
        available(user)
      end
    ).scoped
  end

  def self.available(user)
    (user ? available_2_user(user) : available_2_all).scoped
  end
  
  # Scopes
  scope :private_only, ->(user) { 
    where(%(
      klasses.private = FALSE or courses.originator_id = :user_id or instructors.user_id = :user_id or (
        students.user_id = :user_id and klasses.private = TRUE and (
          enrollments.active = TRUE or enrollments.accepted_or_declined_at is null or enrollments.dropped_at is not null
        )
      )
    ), :user_id => user.id)

  }
  scope :public_only, -> { where("klasses.private = FALSE") }
  scope :featured, -> { where("klasses.featured = TRUE ") }
  scope :looking_ahead, -> { 
    where(%(
      (klasses.begins_on <= :today and (klasses.ends_on is null or klasses.ends_on >= :today)) or 
      (klasses.begins_on > :today and (klasses.begins_on < :lookahead_day))
    ), :today => Time.zone.today, :lookahead_day => Time.zone.today + 60)
  }
  scope :coming, -> { where("klasses.begins_on > :today and (klasses.begins_on < :lookahead_day)", 
        :today => Time.zone.today, :lookahead_day => Time.zone.today + 60)
  }
  scope :active, -> { where("klasses.active = TRUE and klasses.approved = TRUE") }
  scope :open, -> { where("klasses.begins_on <= :today and (klasses.ends_on is null or klasses.ends_on >= :today)", :today => Time.zone.today) }
  scope :closed, -> { where("klasses.ends_on < :today", :today => Time.zone.today) }
  scope :enrolled, ->(user) { 
    joins(:students).where("students.user_id = :user_id and enrollments.active = TRUE and enrollments.dropped_at is NULL", :user_id => user.id) 
  }
  
  # whole
  scope :available_2_user, ->(user) {
    joins(:course).
    joins('left outer join instructors ON instructors.course_id = courses.id').
    joins('left outer join enrollments on klasses.id = enrollments.klass_id').
    joins('left outer join students on enrollments.student_id = students.id').
    active.looking_ahead.private_only(user).distinct
  }
  
  scope :available_2_all, -> {
    joins(:course).active.looking_ahead.public_only.distinct
  }
  
  def can_enroll?(user, student)
    can = self.active && ( self.open? || self.future? ) && 
      allow_enrollment && ( 
        user.blank? || !user.has_role?(:admin) && !KlassEnrollment.staff?(user, course)
      )
    
    if can and student.present?
      e_s = self.enrollments.where(%(
        enrollments.student_id = #{student.id} and 
        enrollments.active = TRUE and 
        enrollments.dropped_at is NULL
      )).to_a
      can = e_s.blank?
    end
    
    can
  end
  
  def can_no_longer_enroll?(user, student)
    past? && can_enroll?(user, student)
  end
  
  def enrolled?(student)
    false || ( student && (self.open? || self.past?) && self.enrollments.where(%(
      enrollments.student_id = #{student.id} and 
      enrollments.active = TRUE
    )).exists? )
  end
  
  def previously_enrolled?(student)
    past? && enrolled?(student)
  end
  
  def dropped?(student)
  	false || ( student && self.enrollments.where(%(
      enrollments.student_id = #{student.id} and 
      enrollments.active = FALSE and
      enrollments.dropped_at is not NULL
    )).exists? )
  end
  
  def invited_and_not_yet_accepted?(user)
  	self.private && self.students.where(%(
      enrollments.active = FALSE and 
      enrollments.invited_at is not NULL and 
      enrollments.accepted_or_declined_at is NULL
    )).exists?(:user_id => user.id)
  end
  
  def invited_and_accepted?(user)
  	self.private && self.students.where(%(
      ( enrollments.active = TRUE or  
        enrollments.dropped_at is not NULL  
      ) and 
      enrollments.invited_at is not NULL and 
      enrollments.accepted_or_declined_at is not NULL
    )).exists?(:user_id => user.id)
  end
  
  def invited_but_declined?(user)
  	self.private && self.students.where(%(
    enrollments.active = FALSE and 
    enrollments.dropped_at is NULL and  
    enrollments.invited_at is not NULL and 
    enrollments.accepted_or_declined_at is not NULL
    )).exists?(:user_id => user.id)
  end
  
  def open?
  	self.begins_on <= Time.zone.today && (self.ends_on.blank? || self.ends_on >= Time.zone.today)
  end
  
  def past?
  	self.ends_on.present? && self.ends_on < Time.zone.today
  end
  
  def future?
  	self.begins_on > Time.zone.today
  end
  
  def name
    #course.name

    name = self.slug.include?(":") ? self.slug.split(':').last : self.slug
    name << " ("
    name << I18n.l(self.begins_on)
    if self.ends_on.present?
      name << ' - '
      name << I18n.l(self.ends_on)
    end
    name << ") "
   
    name
  end

  # To be overridden by any payment plugin
  def free?
    free || (respond_to?(:required_for?) && !required_for?(:all))
  end

  def instructors
    instructors = self.course.instructors.where("role <> :role", :role => 'technician').order(:order).to_a 
    if instructors.blank?
      instructors = [ Instructor.new(:user_id => self.course.originator_id, :role => I18n.t('config.staff.instructor'))]
    end

    instructors
  end

  # NOTE: mysql-specific
  def upcoming_deadlines(in_days = 5, limit=10)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      Assessment.select("assessments.name, (klasses.begins_on + (date(assessments.to_datetime) - assessments.based_on) + assessments.to_datetime::time) as closes_at").
      joins(:course => :klasses).
      where("
        :today >= (klasses.begins_on + (date(assessments.from_datetime) - assessments.based_on) + assessments.from_datetime::time) and
        assessments.to_datetime is not null and 
        (klasses.begins_on + (date(assessments.to_datetime) - assessments.based_on) + assessments.to_datetime::time) between :today and :future and
        klasses.id = :klass_id
      ", :today => Time.zone.now, :future => (Time.zone.today + in_days).to_time, :klass_id => self.id).order('closes_at DESC').limit(limit)
    else
      Assessment.select("assessments.name, ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.to_datetime), '23:59:59')), INTERVAL (DATE(assessments.to_datetime) - assessments.based_on) DAY) as closes_at").
      joins(:course => :klasses).
      where("
        :today >= ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.from_datetime), '00:00:00')), INTERVAL (DATE(assessments.from_datetime) - assessments.based_on) DAY) and
        assessments.to_datetime is not null and 
        ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.to_datetime), '23:59:59')), INTERVAL (DATE(assessments.to_datetime) - assessments.based_on) DAY) between :today and :future and
        klasses.id = :klass_id
      ", :today => Time.zone.now, :future => (Time.zone.today + in_days).to_time, :klass_id => self.id).order('closes_at DESC').limit(limit)
    end
  end
  
  def final_score(student_id, method= :average)
    report = GradeDistribution.final_score_report(self, student_id).to_a
    total_score = 0.0
    exams_score = 0.0
    detail = {}
    report.each do |item|
      score = 0.0
      key = "#{item.level}_#{item.kind}"
      if item.scored > 0
        case method
        when :average
          score = [ item.scored / item.avg_points, 1.0 ].min * 1.0 * item.grade
        else 
          score = [ item.scored / item.max_points, 1.0 ].min * 1.0 * item.grade
        end

        total_score += score
      else
        score = 0
      end

      unless %w(attendance participation).include? item.kind
        exams_score += score
      else
        detail[key] = score
      end
    end
    
    detail["course_assessment"] = exams_score

    total_score = total_score.round(2)
    
    letter = nil
    course.config["grading"]["letters"].each do |k, v|
      if total_score >= v
        letter = k
        break
      end
    end
    finn = { score: total_score, letter: letter, detail: detail }
  end
  
  before_validation do |klass|
    if klass.slug and klass.slug.include?(":")
      klass.slug = klass.slug.split(':')[1]
    end
  end

  before_save do |klass|
    if klass.slug and !klass.slug.include?(":")
      klass.slug = %(#{klass.course.slug}:#{klass.slug})
    end
  end
  
  after_create do |klass|
    forums = klass.course.forums.where(active: true)
    forums.each do |f|
      klass.forums.create(:name => f.name, :about => f.about, graded: f.graded)
    end if forums.present?
    
    lecture_forum = klass.forums.create(:name => I18n.t('page.titles.lecture_comments'), 
      :about => I18n.t("page.text.lecture_comments"), :lecture_comments => true)
      
    Lecture.joins(:unit).where('units.course_id = :course_id', :course_id => klass.course_id).each do |lecture|
      lecture_forum.transaction do
        topic = lecture_forum.topics.create(:name => lecture.name, :about => lecture.about, 
                  :author => lecture.unit.course.originator)
        LectureDiscussion.where(klass_id: klass.id, topic_id: topic.id,
          forum_id: lecture_forum.id, lecture_id: lecture.id).create
      end
    end
    
    graded_discussions_forum = klass.forums.create(:name => I18n.t('page.titles.graded_discussions'), 
      :about => I18n.t("page.text.graded_discussions"), :graded => true)
  end
  
end
