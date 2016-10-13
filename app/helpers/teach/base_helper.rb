module Teach::BaseHelper
  def question_bank_path(action, kind, assessment = nil, bank=nil)
    options = {:action => action, :controller => 'questions',
                :course_id => @course.id, :unit_id => (@unit ? @unit.id : nil),
                :lecture_id => (@lecture ? @lecture.id : nil), :s => kind }
    options[:a] = assessment.id if assessment && assessment.is_a?(Assessment)
    options[:b] = bank if bank
    url_for(options)
  end

  def ui_course_klass_links(klass)
		links = [
		  link(:klass, :edit, edit_teach_course_klass_path(@course, klass), remote: true, class: 'ui positive button'),
      link(:klass, :show, learn_klass_path(klass), as: :student_view, class: 'ui secondary button')]

    items = []
    if klass.ready_to_approve
      if current_user && current_user.has_role?(:admin)
        items << link(:klass, klass.approved ? :disapprove : :approve, approve_teach_course_klass_path(@course, klass),
            :method => :put, class: "item")
        items << link(:klass, :unready, ready_teach_course_klass_path(@course, klass), :method => :put, class: 'item')
      end
    else
      items << link(:klass, :ready, ready_teach_course_klass_path(@course, klass), :method => :put, class: 'item')
    end
    items << nil
    items << link(:klass, :destroy, teach_course_klass_path(@course, klass), :confirm => true, :method => :delete, class: 'item')

    links << ui_dropdown_button(t('page.text.more'), items, class: 'ui dropdown secondary basic button')
    
    links
  end

  def active_klass_section?(section)
    (params[:show] || 'about') == section
  end
end
