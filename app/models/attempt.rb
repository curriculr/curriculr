class Attempt < ActiveRecord::Base
  include Actionable
  
  belongs_to :klass
  belongs_to :student
  belongs_to :assessment
  
  serialize :test
  
  attr_accessor :questions, :invideo
  def question_attributes=(attributes)
    #TODO
  end
  
  def show_answer?
    return true if assessment.show_answer == 'always'

    case assessment.show_answer
    when 'during_attempt'
      state == 1
    when 'after_attempt'
      state == 2
    when 'after_deadline'
      assessment.to_datetime.present? && assessment.closes_at_datetime(klass) < Time.zone.now
    else
      false 
    end
  end
  
  def result(q, i)
    result = nil
    if state == 2 
		  if test[i][:g] > 0 
        if test[i][:c] == q.options_count 
			    result = :correct
        else
          result = :partially_correct
        end
		  elsif test[i][:p] > 0
		    result = :incorrect
		  end 
    end
    
    result
  end
  
  scope :for, ->(klass, student, assessment) {
    where(:klass => klass, :student => student, :assessment => assessment).order(:updated_at)
  }

  def scored_points
    points = 0.0;
    self.test.each do |q|
      points += q[:g]
    end
    
    points.round(2)
  end
  
  # callbacks
  after_create do
    log_activity('started', klass, student, assessment)
  end
  
  after_update do 
    log_activity('finished', klass, student, assessment) if state == 2

    if assessment.lecture && !assessment.invideo?
      assessment.lecture.log_attendance(klass, student, assessment)
    end
  end
end
