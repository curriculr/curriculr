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
      {link: t('page.title.question_banks'), to: teach_course_questions_path(@course), active:  controller_name == 'questions'}]
      
    add_to_app_menu :course, [  
      {link: t('activerecord.models.setting', count: 3), to: settings_teach_course_path(@course), active: action_name == 'settings'},
      {link: t('helpers.submit.dashboard'), to: teach_course_dashboard_path(@course), active: controller_name == 'dashboard'}], :administration

      #link(:course, :destroy, teach_course_path(@course), :method => :delete, :confirm => true, class: 'item')]
  
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
end
