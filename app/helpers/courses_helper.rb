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
      link_to(css_icon(:university, 2) + t("helpers.submit.main"), teach_course_path(@course), :class => "item #{any_active ? nil : 'active'}"),
      :_,
      (link_to teach_course_units_path(@course), :class => "item #{controller_name == 'units' ? 'active' : nil}" do
        raw Lecture.model_name.human(count: 3) + '&nbsp;' + content_tag(:span, @course.units_count, :class => css_badge)
      end),
     (link_to teach_course_media_path(@course), :class => "item #{controller_name == 'media' ? 'active' : nil}" do
        raw Medium.model_name.human(count: 3) + '&nbsp;' + content_tag(:span, @course.media_count, :class => css_badge)
      end),
      (link_to teach_course_klasses_path(@course), :class => "item #{controller_name.in?([ 'klasses', 'forums', 'updates' ]) ? 'active' : nil}" do
        raw Klass.model_name.human(count: 3) + '&nbsp;' + content_tag(:span, @course.klasses_count, :class => css_badge)
      end),
      link_to(t('page.title.question_banks'), teach_course_questions_path(@course), :class => "item #{controller_name == 'questions' ? 'active' : nil}"),
      :_,
      link_to(css_icon(:cog, 2) + t('activerecord.models.setting', count: 3), settings_teach_course_path(@course), :class => "item #{action_name == 'settings' ? 'active' : nil}"),
      link_to(t('helpers.submit.dashboard').html_safe, teach_course_dashboard_path(@course), :class => "item #{controller_name == 'dashboard' ? 'active' : nil}"),
      :_,
      link(:course, :destroy, teach_course_path(@course), :method => :delete, :confirm => true, class: 'item')]
  
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
