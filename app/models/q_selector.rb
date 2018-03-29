class QSelector < ActiveRecord::Base
  belongs_to :assessment, :counter_cache => true
  belongs_to :question
  belongs_to :lecture
  belongs_to :unit
  serialize :tags
  
  validates :questions_count, :numericality => {:only_integer => true, :greater_than => 0}
  validates :order, :numericality => {:only_integer => true}
  validates :points, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :unless => Proc.new { |q| q.assessment.survey? }
  validate :has_enough_questions
  
  def has_enough_questions
    if self.questions.count < self.questions_count
      errors.add :questions_count, :not_enough_questions
    end
  end
  
  def questions
    if self.question
      questions = [self.question]
      questions.each {|q| q.points = self.points }
      questions
    else
      options = {}
      options[:kind] = self.kind if !self.kind.blank?
      options[:course_id] = self.assessment.course.id
      options[:unit_id] = self.unit.id if self.unit
      options[:lecture_id] = self.lecture.id if self.lecture

      questions = Question.where(options)
      
      unless self.tags.blank? 
        tags = self.tags.reject(&:empty?)
        unless tags.blank?
          questions = questions.tagged_with(tags, :any => true, :on => :banks)
        end
      end
      
      questions = questions.distinct.sample(self.questions_count)
      questions.each {|q| q.points = self.points }
      questions
    end
  end
  
	# Scopes
  default_scope -> { 
    order 'q_selectors.order'
  }
  
  # callbacks
  
  after_initialize do 
    self.tags = self.tags.blank? ? [] : self.tags
  end
  
  before_create do |q_selector|
    q_selector.order = (QSelector.where(assessment_id: q_selector.assessment.id).maximum(:order) || 0) + 1
  end
  
  after_create do 
    assessment = Assessment.find(self.assessment_id)
  	assessment.questions_count += self.questions_count
    assessment.points += self.points
  	assessment.save
  end

  after_update do 
    assessment = Assessment.find(self.assessment_id)
    if self.saved_changes[:questions_count]
    	assessment.questions_count += (self.questions_count - self.saved_changes[:questions_count][0])
    end
    
    assessment.points = 0.0
    assessment.q_selectors.each do |s|
      assessment.points += s.points * s.questions_count
    end
    
    assessment.save!
  end
  
  after_destroy do
    assessment = Assessment.find(self.assessment_id)
  	assessment.questions_count -= self.questions_count
    assessment.points -= (self.points * self.questions_count)
  	assessment.save!
  end

end