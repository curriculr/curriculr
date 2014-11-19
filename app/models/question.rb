class Question < ActiveRecord::Base
  include Actionable
  acts_as_taggable_on :tags, :banks 
  
  belongs_to :course
  belongs_to :unit
  belongs_to :lecture
  
  attr_accessor :points, :unit_lectures
  
  has_many :options, :dependent => :destroy
  accepts_nested_attributes_for :options, :allow_destroy => true
  def answer # Used in attempt
    answer = {}
    options.each do |o|
      answer[o.id] = o.answer
    end
    
    answer
  end
  def answers # used in questions bank
    case kind
    when 'pick_one'
      (options.select {|o| o.answer == '1'}).first.id
    when 'pick_many'
      options.map {|o| o.id if o.answer == '1'}
    end
  end
  
	# Validation Rules
	validates :question, :kind, :course_id, :bank_list, :presence => true
	validates :hint, :explanation, :length => {:maximum => 400 }
	validate :has_valid_options?
  
	def has_valid_options?
    return if kind.blank?
    
    blank_option = false
		q_options = []
    q_answers = []
    count = 0
    blank = false
    missing_option = false
    missing_answer = false
    missing_answer_options = false
    is_survey = 'survey'.in?(bank_list)
		options.each do |o| 
			unless o.marked_for_destruction?
				q_options << o.option unless o.option.blank?
				q_answers << o.answer unless o.answer.blank?
        
        blank = true if o.option.blank? and o.answer.blank? and o.answer_options.blank?
        missing_option = true if o.option.blank?
        missing_answer = true if o.answer.blank?
        missing_answer_options = true if o.answer_options.blank?
        count += 1
			end 
		end
  
		if kind.to_s == 'simple'
      if !is_survey and q_answers.empty?
			  errors.add :options, I18n.t('errors.models.question.answers.blank')
      end
      if count > 1
        errors.add :options, I18n.t('errors.models.question.answers.not_one')
      end
    else
      if blank
        errors.add :options, I18n.t('errors.models.question.options.blank')
      end
    
      if Option.render_options[kind.to_sym][:count] > 1 and q_options.count < 2
        errors.add :options, I18n.t('errors.models.question.options.less_than_two')
      end
      
      if missing_option and Option.render_options[kind.to_sym][:option]
        errors.add :options, I18n.t('errors.models.question.options.blank_option')
      end
      
      if !is_survey and missing_answer and Option.render_options[kind.to_sym][:answer]
        errors.add :options, I18n.t('errors.models.question.answers.blank')
      end
      
      if missing_answer_options and Option.render_options[kind.to_sym][:answer_options]
        errors.add :options, I18n.t('errors.models.question.options.blank_answer_options')
      end
      
      if !is_survey and (kind.to_s == 'pick_one' or kind.to_s == 'pick_many')
        a_count = 0
        q_answers.each {|a| a_count += 1 if a == '1'}
        if kind.to_s == 'pick_many' and a_count < 2
          errors.add :options, I18n.t('errors.models.question.answers.less_than_two')
        elsif kind.to_s == 'pick_one' and a_count != 1
          errors.add :options, I18n.t('errors.models.question.answers.not_one')
        end
      end
		end
	end
 
  # call back
  before_save do 
    if self.kind.to_s == 'sort'
      self.options.each_with_index  do |option, ndx|
        option.answer = "#{ndx + 1}"
      end
    end
  end

  before_destroy do |question|
    QSelector.where(:question => question).destroy_all
  end
end

