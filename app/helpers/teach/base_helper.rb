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
      nil,
		  link(:klass, :destroy, teach_course_klass_path(@course, klass),
		    :confirm => true, :method => :delete, class: 'ui negative button'),
      nil,
      link(:klass, :show, learn_klass_path(klass), as: :student_view, class: 'ui positive basic button')
    ]

    if klass.ready_to_approve
      if current_user && current_user.has_role?(:admin)
        links << nil
        links << link(:klass, klass.approved ? :disapprove : :approve, approve_teach_course_klass_path(@course, klass),
          :method => :put, class: "ui #{klass.approved ? 'negative' : 'positive'} basic button")
        links << link(:klass, :unready, ready_teach_course_klass_path(@course, klass), :method => :put, class: 'ui negative basic button')
      end
    else
      links << nil
      links << link(:klass, :ready, ready_teach_course_klass_path(@course, klass), :method => :put, class: 'ui positive basic button')

    end

    links
  end

  # def active_course_section?(section)
  #   (params[:show] || 'syllabus') == section
  # end
  #
  # def active_unit_section?(section)
  #   (params[:show] || 'lectures') == section
  #   # if @lecture
  #   #   if section =='lectures'
  #   #     'active'
  #   #   else
  #   #     nil
  #   #   end
  #   # else
  #   #   if params[:show] == section
  #   #     return 'active'
  #   #   else
  #   #     if section =='lectures' && (params[:show].blank? || params[:show] == 'lectures')
  #   #       'active'
  #   #     else
  #   #       nil
  #   #     end
  #   #   end
  #   # end
  # end
  #
  def active_klass_section?(section)
    (params[:show] || 'about') == section
  end
end
