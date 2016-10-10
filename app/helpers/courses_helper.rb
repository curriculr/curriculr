module CoursesHelper  
  def question_banks(exclude_survey= false)
    banks = t('config.question.bank').stringify_keys 
    if @course.config['question_banks'].present?
      banks = banks.reverse_merge(Hash[ @course.config['question_banks'].map do |b| [b, b] end ]) 
    end
    
    banks.delete('survey') if exclude_survey

    banks
  end
  
  def course_breadcrumbs(here, for_questions = false)
    items = []
    if @lecture
      items << {name: here, link: nil}
      
      if for_questions
        items << {name: @lecture.name, link: teach_course_unit_lecture_questions_path(@course, @unit, @lecture, :a => params[:a], :b => @bank)}
        items << {name: @unit.name, link: teach_course_unit_questions_path(@course, @unit, :a => params[:a], :b => @bank)}
        items << {name: Course.model_name.human, link: teach_course_questions_path(@course, :a => params[:a], :b => @bank)}
      else
        items << {name: @lecture.name, link: teach_course_unit_lecture_path(@course, @unit, @lecture)}
        items << {name: @unit.name, link: teach_course_unit_path(@course, @unit)}
        items << {name: Course.model_name.human, link: teach_course_path(@course)}
      end
    elsif @unit
      items << {name: here, link: nil}
          
      if for_questions
        items << {name: @unit.name, link: teach_course_unit_questions_path(@course, @unit, :a => params[:a], :b => @bank)}
        items << {name: Course.model_name.human, link: teach_course_questions_path(@course, :a => params[:a], :b => @bank)}
      else
        items << {name: @unit.name, link: teach_course_unit_path(@course, @unit)}
        items << {name: Course.model_name.human, link: teach_course_path(@course)}
      end
    elsif @course
      items << {name: here, link: nil}
          
      if for_questions
        items << {name: Course.model_name.human, link: teach_course_questions_path(@course, :a => params[:a], :b => @bank)}
      else
        items << {name: Course.model_name.human, link: teach_course_path(@course)}
      end
    end
    
    unless items.empty?
      content_tag :div, class: 'ui breadcrumb' do
        crumbs = items.reverse.map{|i| i[:link] ? link_to(i[:name], i[:link], class: 'section') : content_tag(:div, i[:name], class: 'active section')}
        crumbs.join(ui_icon('right angle icon divider')).html_safe
      end
    end
  end
end
