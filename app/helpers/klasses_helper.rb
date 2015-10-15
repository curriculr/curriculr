module KlassesHelper
  def klass_actions(klass, in_preview = false, right = false)
    links = []
    align = right ? :right : nil
    if klass.enrolled?(current_student) || klass.previously_enrolled?(current_student)
      #go2class or #go2class_past
      links << link(:klass, :goto, main_app.learn_klass_path(klass), :class => css(button: :primary, align: align))
    elsif klass.can_enroll?(current_user, current_student)
      if (controller_name == 'klasses' && action_name == 'show') ||
         (controller_name == 'lectures' && action_name == 'index') || @lecture
        # Enrollment links
        if klass.dropped?(current_student)
          #enroll again
          links << link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass),
            :class => css(button: :success, align: align), :method => :post, :as => :again)
        elsif !klass.private || klass.invited_and_not_yet_accepted?(current_user)
          #enroll
          links << link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass),
            :class => css(button: :success, align: align), :method => :post, :as => :'4_free')
        end

        mountable_fragments(:klass_enrollment_actions, klass: klass, action: :enroll, previewed: in_preview, links: links, right: right)

        if klass.invited_and_not_yet_accepted?(current_user)
          #decline
          links << link(:enrollment, :decline, main_app.decline_learn_klass_path(klass),
                      :class => css(button: :danger, align: align), :method => :put)
        end

        if !in_preview and klass.previewed
          #preview
          links << link(:enrollment, :preview,  main_app.learn_klass_lectures_path(klass),
              :class => css(button: :primary, align: align))
        end
      else
        #learn_more
        links << link(:klass, :learn_more, learn_klass_path(klass), :class => css_button(:primary))
        mountable_fragments(:klass_flags_actions, klass: klass, previewed: in_preview, links: links, right: right)
      end
    elsif current_user && staff?(current_user, klass)
      #admin or faculty
      links << link(:klass, :goto, main_app.teach_course_klass_path(klass.course, klass), :class => css(button: :primary, align: align))
    end

    links.join(' ').html_safe
  end

  def ui_klass_enrollment_action(klass, action, previewed = false, right = false)
    if action == :enroll
      klass_actions(klass, previewed, right)
    else
      link(:klass, :drop, main_app.drop_learn_klass_path(@klass), method: :put, confirm: true)
    end
  end
end
