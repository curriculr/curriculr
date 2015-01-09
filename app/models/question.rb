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
      case kind.to_sym
      when :sort
        o.option_items.each_with_index do |item, i|
          answer[i + 1] = item
        end
      when :match
        answers = o.answer_options_items
        o.option_items.each_with_index do |item, i|
          answer[i + 1] = answers[i]
        end
      else
        answer[o.id] = o.answer
      end
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
    
    render_options = Option.render_options[kind.to_sym]
		extracted_items = []
    q_a_options = []
    q_b_options = []
    options_count = 0
    has_blank_option = false
    missing_a_option = false
    missing_b_option = false
    is_survey = 'survey'.in?(bank_list)
		options.each do |o| 
			unless o.marked_for_destruction?
        q_a_options << o.option
        q_b_options << o.answer_options
        extracted_items << o.extract_items_from_multiline_option

        has_blank_option = true if (render_options[:option] && o.option.blank?) && (
          render_options[:answer_options].blank? || (render_options[:answer_options] && o.answer_options.blank?)
        )

        o.answer_options.blank?
        missing_a_option = true if render_options[:option] && o.option.blank?
        missing_b_option = true if render_options[:answer_options] && o.answer_options.blank?

        options_count += 1
			end 
		end

    err_messages = []
    a_options = q_a_options.map
    # Validate counts
    if render_options[:count] == 1 
      if options_count != 1
        err_messages << I18n.t('errors.models.question.options_not_one', name: I18n.t("page.text.#{render_options[:name]}"))
      end
    else
      if options_count < render_options[:min]
        err_messages << I18n.t('errors.models.question.options_less_than', count: render_options[:min], name: I18n.t("page.text.#{render_options[:name]}"))
      end

      if kind.to_s == 'pick_one' || kind.to_s == 'pick_many'
        if (q_a_options.select{|o| o.blank? || o.strip.blank?}).present?
          err_messages << I18n.t('errors.models.question.option_blank')
        end

        a_count = (q_b_options.select{|o| o.present? && o != '0'}).count
        if kind.to_s == 'pick_many' and a_count < 2
          err_messages << I18n.t('errors.models.question.answers_less_than', count: 2)
        elsif kind.to_s == 'pick_one' and a_count != 1
          err_messages << I18n.t('errors.models.question.answers_not_one')
        end
      end
    end

    extracted_items.each do |e|
      if render_options[:option][:min] && render_options[:option][:min] > 1
        if e.first.count < render_options[:option][:min]
          err_messages << I18n.t('errors.models.question.items_less_than', count: render_options[:option][:min])
        end
      end

      if render_options[:answer_options] && render_options[:answer_options][:min] && render_options[:answer_options][:min] > 1
        if e.last.count < render_options[:answer_options][:min]
          err_messages << I18n.t('errors.models.question.items_less_than', count: render_options[:answer_options][:min])
        end
      end
    end

    # Validate blanks
    if has_blank_option
      err_messages << I18n.t('errors.models.question.option_blank')
    end

    if err_messages.present?
      errors.add :options, err_messages.sort.uniq.join(' ')
    end
	end
 
  def survey?
    'survey'.in?(bank_list)
  end
  
  # call back
  before_save do 
    self.options.each_with_index  do |option, ndx|
      case self.kind.to_sym
      when :fill_one, :fill_many
        option.answer = option.option.strip
      when :pick_2_fill
        option.answer = option.option_items.first
      when :pick_one, :pick_many, :match
        option.answer = option.answer_options_items.first
      when :sort
        option.answer = [1..option.option_items.count].join("\n")
      end
    end
  end

  before_destroy do |question|
    QSelector.where(:question => question).destroy_all
  end
end

