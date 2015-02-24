class Unit < ActiveRecord::Base
  include WithMaterials
  
  belongs_to :course, :counter_cache => true
	has_many :lectures, :dependent => :destroy
	has_many :assessments, :dependent => :destroy
  has_many :pages, :dependent => :destroy, :as => :owner
  has_many :updates, :dependent => :destroy

	# Validation Rules
	validates :name, :presence => true, :length => {:maximum => 100 }
	validates :on_date, :based_on, :about , :presence => true
  validates :for_days, :numericality => {:only_integer => true, :greater_than => 0, :allow_nil => true }
	validates :order, :numericality => {:only_integer => true }
  validate :proper_on_date

  def proper_on_date
    if on_date.present? and on_date < based_on
      errors.add :on_date, :must_be_after_date, :date => based_on
    end 
  end
  
  def contents(for_student = false)
    data = []
    data += self.materials_of_kind([:document, :other]).to_a

    if for_student
      data += self.pages.where(:published => true).to_a
      data += self.assessments.where(:lecture_id => nil, :ready => true).to_a
    else
      data += self.pages.to_a
      data += self.assessments.to_a
    end
    
    data
  end

  # default_scope -> { 
  #   order 'units.order'
  # }
  
	scope :open, ->(klass, student) {
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      date_clause = "(units.on_date - units.based_on) <= (DATE :today - klasses.begins_on) and 
        (units.for_days is null or 
        (klasses.begins_on + (units.on_date - units.based_on) + units.for_days)"
    else
      date_clause = "(units.on_date - units.based_on) <= (DATE(:today) - klasses.begins_on) and 
        (units.for_days is null or 
        adddate(klasses.begins_on, (units.on_date - units.based_on) + units.for_days)"
    end

    q = joins(:course => :klasses).where("
      (klasses.ends_on is null or (klasses.ends_on < :today and klasses.lectures_on_closed = TRUE ) or
      (klasses.ends_on > :today and #{date_clause} > :today))) and
      courses.id = :course_id and klasses.id = :klass_id ", 
      :course_id => klass.course.id, :klass_id => klass.id, :today => Time.zone.today)
      
    unless klass.enrolled?(student) || (student && KlassEnrollment.staff?(student.user, klass.course))
      q = q.where('klasses.previewed = TRUE and units.previewed = TRUE') 
    end
    
    q.order('units.order')
  }
        
  def pagers
    units = Unit.where(course_id: self.course.id).order(:order).to_a
      
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
  
  def open?(klass)
    today = Time.zone.today
    on_day = (self.on_date - self.based_on).to_i
    on_day <= (today - klass.begins_on).to_i and (self.for_days.blank? or (klass.begins_on + on_day + self.for_days) > today)
  end
    
  # callbacks
  before_create do |unit|
    unit.order = (Unit.where(course_id: unit.course.id).maximum(:order) || 0) + 1
  end
  
end
