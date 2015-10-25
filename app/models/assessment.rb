class Assessment < ActiveRecord::Base
  include Actionable

  acts_as_taggable_on :tags, :events

  belongs_to :course, :counter_cache => true
  belongs_to :unit, :counter_cache => true
  belongs_to :lecture, :counter_cache => true

  has_many :q_selectors, :dependent => :destroy
  accepts_nested_attributes_for :q_selectors, :allow_destroy => true

	# Validation Rules
	validates :name, :presence => true, :length => {:maximum => 100 }
	validates :allowed_attempts, :numericality => { :only_integer => true, :greater_than => 0, :allow_nil => true }
  validates :invideo_id, :numericality => { :only_integer => true, :greater_than => 0, :allow_nil => true }
  validates :invideo_at, :numericality => { :only_integer => true, :greater_than => 0, :allow_nil => true }
	validates :droppable_attempts, :penalty, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :kind, :based_on, :from_datetime, :presence => true
  validate :proper_attempts
  validate :proper_from_and_to_datetimes
  validate :proper_invideo

  def questions
    questions = []
    self.q_selectors.each do |s|
      questions += s.questions
    end

    questions.uniq!

    questions
  end

  def proper_attempts
    if allowed_attempts.present? && droppable_attempts >= allowed_attempts
      errors.add :droppable_attempts, :less_than_or_equal_to, :count => allowed_attempts
    end
  end

  def proper_from_and_to_datetimes
    if from_datetime.present? && from_datetime.to_date < based_on
      errors.add :from_datetime, :must_be_after_date, :date => based_on
    end

    if from_datetime.present? && to_datetime.present? && from_datetime >= to_datetime
      errors.add :to_datetime, :must_be_after_start_date
    end
  end

  def proper_invideo
    if invideo_id.present? && invideo_at.blank?
      errors.add :invideo_at, :blank
    end

    if invideo_at.present? && invideo_id.blank?
      errors.add :invideo_id, :blank
    end
  end

  def invideo?
    self.lecture.present? && invideo_id.present?
  end

	# Scopes
  def opens_at_datetime(klass)
    from_day = (from_datetime.to_date - based_on).to_i
    date = klass.begins_on + from_day
    from_datetime.change(:year => date.year, :month => date.month, :day => date.day)
  end

  def closes_at_datetime(klass)
    to_day = (to_datetime.to_date - based_on).to_i
    date = klass.begins_on + to_day
    to_datetime.change(:year => date.year, :month => date.month, :day => date.day)
  end

  def hours_to_close(klass)
    (closes_at_datetime(klass) - Time.zone.now)/3600.0
  end

  def survey?
    kind == 'survey'
  end

  # NOTE: mysql-specific # use
  scope :course_level, -> { where(:unit_id => nil, :lecture_id => nil) }
  scope :unit_level, ->{ where(:lecture_id => nil) }
	scope :open, ->(klass) {
    clause = joins(:q_selectors, :course => :klasses)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      clause.where(%(
        :as_of >= (klasses.begins_on + (date(assessments.from_datetime) - assessments.based_on) + assessments.from_datetime::time) and
        ( assessments.to_datetime is null or
          :as_of < (klasses.begins_on + (date(assessments.to_datetime) - assessments.based_on) + assessments.to_datetime::time)
        ) and
        klasses.id = :klass_id ), :klass_id => klass.id, :as_of => Time.zone.now)
    else
      clause.where("
        :as_of >= ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.from_datetime), '00:00:00')), INTERVAL (DATE(assessments.from_datetime) - assessments.based_on) DAY) and
        ( assessments.to_datetime is null or
          :as_of < ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.to_datetime), '00:00:00')), INTERVAL (DATE(assessments.to_datetime) - assessments.based_on) DAY)
        ) and
        klasses.id = :klass_id ", :klass_id => klass.id, :as_of => Time.zone.now)
    end
  }

	scope :report, ->(klass, student) {
    clause = joins(:course => :klasses).
      joins("inner join attempts on assessments.id = attempts.assessment_id and attempts.student_id = #{student.id} and attempts.state = 2").
      joins('left outer join units on assessments.unit_id = units.id').
      joins('left outer join lectures on assessments.lecture_id = lectures.id').
      select('assessments.id, assessments.unit_id, assessments.lecture_id, assessments.kind').
      select('assessments.name, assessments.based_on, assessments.from_datetime, assessments.to_datetime').
      select('count(attempts.id) as count, units.name as uname, lectures.name as lname').
      select('min(attempts.score) as min, avg(attempts.score) as avg, max(attempts.score) as max').
      where("assessments.kind <> 'survey'").
      group('assessments.id, assessments.unit_id, assessments.lecture_id, units.name, lectures.name, assessments.kind').
      order('assessments.to_datetime, assessments.from_datetime')
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      clause.where("
        :as_of >= (klasses.begins_on + (date(assessments.from_datetime) - assessments.based_on) + assessments.from_datetime::time) and
        klasses.id = :klass_id ", :klass_id => klass.id, :as_of => Time.zone.now)
    else
      clause.where("
        :as_of >= ADDDATE(ADDTIME(klasses.begins_on, IFNULL(TIME(assessments.from_datetime), '00:00:00')), INTERVAL (DATE(assessments.from_datetime) - assessments.based_on) DAY) and
        klasses.id = :klass_id ", :klass_id => klass.id, :as_of => Time.zone.now)
    end
  }

  def show_answer?(klass)
    if %w(during_attempt after_attempt always).include?(show_answer)
      return true
    elsif show_answer == 'after_deadline' && to_datetime.present?
      if closes_at_datetime(klass) < Time.zone.now
        return true
      end
    end

    false
  end

  def can_be_taken?(klass, student)
    klass.open? && (
      self.allowed_attempts.blank? ||
      Attempt.for(klass, student, self).count < self.allowed_attempts ||
      ( open?(klass) && (attempt = Attempt.for(klass, student, self).last) && attempt.state == 1)
    ) &&
    (self.q_selectors_count > 0 || self.questions_count > 0)
  end

  def score (klass, student)
    if multiattempt_grading == 'average'
      score = Attempt.for(klass, student, self).average(:score)
    else
      score = Attempt.for(klass, student, self).maximum(:score)
    end

    score.nil? ? 0.0 : Float(score).round(2)
  end

  def after_deadline?(klass)
    self.after_deadline && self.to_datetime.present? && self.closes_at_datetime(klass) <= Time.zone.now
  end

  def open?(klass)
    klass.open? && self.ready && self.opens_at_datetime(klass) <= Time.zone.now && (
      self.to_datetime.blank? ||
      self.closes_at_datetime(klass) > Time.zone.now ||
      (self.closes_at_datetime(klass) <= Time.zone.now && self.after_deadline)
    )
  end
end
