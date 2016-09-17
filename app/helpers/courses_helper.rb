module CoursesHelper
  def course_menu
    any_active = (
      controller_name == 'units' ||
      controller_name == 'media' ||
      controller_name.in?([ 'klasses', 'forums', 'updates' ]) ||
      controller_name == 'questions' ||
      action_name == 'settings' ||
      controller_name == 'dashboard'
    )

    add_to_app_menu :course, [
      {link: t("helpers.submit.main"), to: teach_course_path(@course), active: !any_active},
      {link: raw(Lecture.model_name.human(count: 3) + content_tag(:div, @course.units_count, :class => "ui left pointing label")), to: teach_course_units_path(@course), active: controller_name == 'units'},
      {link: raw(Medium.model_name.human(count: 3) + content_tag(:div, @course.media_count, :class => "ui left pointing label")), to: teach_course_media_path(@course), active: controller_name == 'media' },
      {link: raw(Klass.model_name.human(count: 3) + content_tag(:div, @course.klasses_count, :class => "ui left pointing label")), to: teach_course_klasses_path(@course), active: controller_name.in?(['klasses', 'forums', 'updates'])},
      {link: Question.model_name.human(count: 3), to: teach_course_questions_path(@course), active:  controller_name == 'questions'},
      {link: t('activerecord.models.setting', count: 3), to: settings_teach_course_path(@course), active: action_name == 'settings'}]
  
    mountable_fragments :course_menu
  end
  
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
