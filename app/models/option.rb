class Option < ActiveRecord::Base
  belongs_to :question, :counter_cache => true
  
  def self.render_options 
    {
      simple: {option: false, answer: true, answer_options: false, count: 1, cols: 1},
      fill: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
      pick_2_fill: {option: true, answer: true, answer_options: true, count: 99, cols: 3},
      pick_one: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
      pick_many: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
      match: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
      underline: {option: true, answer: true, answer_options: false, count: 99, cols: 2},
      sort: {option: true, answer: false, answer_options: false, count: 99, cols: 2}
    }
  end
  
  default_scope -> { 
    order 'options.order'
  }
  
  before_create do |option|
    option.order = (Option.where(question_id: option.question.id).maximum(:order) || 0) + 1
  end
end
