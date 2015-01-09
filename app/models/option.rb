class Option < ActiveRecord::Base
  belongs_to :question, :counter_cache => true
  
  # def self.render_options 
  #   {
  #     simple: {option: false, answer: true, answer_options: false, count: 1, cols: 1},
  #     fill: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
  #     pick_2_fill: {option: true, answer: true, answer_options: true, count: 99, cols: 3},
  #     pick_one: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
  #     pick_many: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
  #     match: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
  #     underline: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
  #     sort: {option: true, answer: false, answer_options: false, count: 99, cols: 2}
  #   }
  # end
  
  def self.render_options 
    {
      fill_one: {
        option: { name: :answer, lines: 1 }, 
        answer_options: false, count: 1, cols: 1
      },
      fill_many: {
        option: { name: :blank_answer, lines: 1 }, 
        answer_options: false, count: 99, cols: 1, name: :blank, min: 1
      },
      pick_2_fill: {
        option: { name: :blank_options, lines: 5, min: 2 }, 
        answer_options: false, count: 99, cols: 1, name: :blank, min: 1
      },
      pick_one: {
        option: { name: :option, lines: 2 },
        answer_options: { name: :answer? }, count: 99, cols: 2, name: :option, min: 2
      },
      pick_many: {
        option: { name: :option, lines: 2 },
        answer_options: { name: :answer? }, count: 99, cols: 2, name: :option, min: 3
      },
      match: {
        option: { name: :side_1, lines: 10, min: 2 },
        answer_options: { name: :side_2, lines: 10, min: 2 }, count: 1, cols: 2
      },
      sort: {
        option: { name: :items, lines: 10, min: 2},
        answer_options: false, count: 1, cols: 1
      }
    }
  end

  default_scope -> { 
    order 'options.order'
  }
  
  before_create do |option|
    option.order = (Option.where(question_id: option.question.id).maximum(:order) || 0) + 1
  end

  def extract_items_from_multiline_option
    [option_items, answer_options_items]
  end

  def option_items
    option.present? ? option.split(/\n\r?/).select{|o| o.strip.present?}.map{|o| o.strip } : []
  end

  def answer_options_items
    answer_options.present? ? answer_options.split(/\n\r?/).select{|o| o.strip.present?}.map{|o| o.strip } : []
  end
end
