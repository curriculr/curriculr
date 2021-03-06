class Unit < ActiveRecord::Base
  include WithMaterials

  belongs_to :course, :counter_cache => true
	has_many :lectures, :dependent => :destroy
	has_many :assessments, :dependent => :destroy
  has_many :pages, :dependent => :destroy, :as => :owner
  has_many :materials, :dependent => :destroy, :as => :owner
  has_many :updates, :dependent => :destroy

	# Validation Rules
	validates :name, :presence => true, :length => {:maximum => 100 }
	validates :on_date, :based_on, :about , :presence => true
  validates :for_days, :numericality => {:only_integer => true, :greater_than => 0, :allow_nil => true }
	validates :order, :numericality => {:only_integer => true }
  validate :proper_on_date

  def proper_on_date
    if on_date.present? && on_date < based_on
      errors.add :on_date, :must_be_after_date, :date => based_on
    end
  end

  def contents(published_only, staff_or_enrolled)
    data = []
    data += self.materials_of_kind([:document, :other]).to_a

    if published_only
      data += self.pages.where(:published => true).to_a
      data += self.assessments.where(:lecture_id => nil, :ready => true).to_a if staff_or_enrolled
    else
      data += self.pages.to_a
      data += self.assessments.to_a if staff_or_enrolled
    end

    data
  end

  # default_scope -> {
  #   order 'units.order'
  # }

  scope :available_based_on_enrollment, -> (klass, student){
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      date_clause = "(units.on_date - units.based_on) <= (DATE :today - DATE :base_date)"
    else
      date_clause = "(units.on_date - units.based_on) <= (DATE(:today) - DATE(:base_date))"
    end
    
    where(date_clause, :base_date => klass.begin_date(student), :today => Time.zone.now)
  }
  
  scope :available_wrt_klass_end_date, -> {
    where("(
            klasses.ends_on is null or 
            (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE) or 
            klasses.ends_on > :today
          )", :today => Time.zone.today) 
  }
  
	scope :open, ->(klass, student, include_everything = false) {
    # if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
    #   date_clause = "(units.on_date - units.based_on) <= (DATE :today - DATE :base_date) and
    #     (units.for_days is null or
    #     (DATE :base_date + (units.on_date - units.based_on) + units.for_days)"
    # else
    #   date_clause = "(units.on_date - units.based_on) <= (DATE(:today) - DATE(:base_date)) and
    #     (units.for_days is null or
    #     adddate(DATE(:base_date), (units.on_date - units.based_on) + units.for_days)"
    # end

    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      date_clause = "(units.for_days is null or
        (DATE :base_date + (units.on_date - units.based_on) + units.for_days) > :today)"
    else
      date_clause = "
        (units.for_days is null or
        adddate(DATE(:base_date), (units.on_date - units.based_on) + units.for_days) > :today"
    end
    
    q = joins(:course => :klasses).where("#{date_clause} and
      courses.id = :course_id and klasses.id = :klass_id",
      :course_id => klass.course.id, :klass_id => klass.id, 
      :today => Time.zone.today,
      :base_date => klass.begin_date(student))
      
    q = q.available_wrt_klass_end_date.available_based_on_enrollment(klass, student)

    unless include_everything || klass.enrolled?(student) || (student && KlassEnrollment.staff?(student.user, klass.course))
      q = q.where('klasses.previewed = TRUE and units.previewed = TRUE')
    end

    q.order('units.order')
  }

  def pagers(klass, student)
    units = Unit.open(klass, student).order(:order).to_a

    index = units.find_index { |u| u.id == self.id }
    count = units.count
    if count <= 1
      [ nil, nil ]
    elsif index == 0
      [ nil, units[index + 1] ]
    elsif index == (count - 1)
      [ units[index - 1], nil ]
    else
      [ units[index - 1], units[index + 1] ]
    end
  end

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
  before_create do |unit|
    unit.order = (Unit.where(course_id: unit.course.id).maximum(:order) || 0) + 1
  end

end
