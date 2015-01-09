module CoursesHelper  
  def question_banks(exclude_survey= false)
    banks = t('config.question.bank').stringify_keys 
    if @course.config['question_banks'].present?
      banks = banks.reverse_merge(Hash[ @course.config['question_banks'].map do |b| [b, b] end ]) 
    end
    
    banks.delete('survey') if exclude_survey

    banks
  end
end
