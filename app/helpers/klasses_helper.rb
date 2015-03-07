module KlassesHelper  
  def klass_actions(klass, in_preview = false)
    links = []
    mountable_links = nil
    
    if klass.enrolled?(current_student)
      #go2class
      links << link(:klass, :goto, learn_klass_path(klass), :class => css_button(:primary))
    elsif klass.can_enroll?(current_user, current_student)
      if controller_name == 'klasses' && action_name == 'show' || @lecture
        if klass.free? 
          if klass.dropped?(current_student)
            #enroll again
            links << link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass), 
              :class => css(button: :success), :method => :post, :as => :again)
          elsif !klass.private || klass.invited_and_not_yet_accepted?(current_user)
            #enroll 
            links << link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass), 
              :class => css(button: :success), :method => :post, :as => :'4_free')
          end
        else
          #add_2_cart
          mountable_links = mountable_fragments(:klass_actions, klass: klass, action: :enroll, previewed: in_preview)
        end

        if klass.invited_and_not_yet_accepted?(current_user)
          #decline
          links << link(:enrollment, :decline, main_app.decline_learn_klass_path(klass), 
                      :class => css(button: :danger), :method => :put)
        end

        if !in_preview and klass.previewed
          #preview
          links << link(:enrollment, :preview,  main_app.learn_klass_lectures_path(klass), 
              :class => css(button: :primary))
        end
      else
        #learn_more
        links << link(:klass, :learn_more, learn_klass_path(klass), :class => css_button(:primary))
        mountable_links = mountable_fragments(:klass_flags, klass: klass, previewed: in_preview)
      end
    elsif klass.previously_enrolled?(current_student)
      #go2class_past
      links << link(:klass, :goto, main_app.learn_klass_path(klass), :class => css_button(:primary))
    end
    
    %(#{links.join(' ').html_safe}  #{mountable_links}).html_safe
  end
  
  def ui_klass_enrollment_action(klass, action, previewed = false, right = false)
    if action == :enroll
      klass_actions(klass, previewed)
    else
      if klass.free? 
        link(:klass, :drop, main_app.drop_learn_klass_path(@klass), method: :put, confirm: true)
      else
        mountable_fragments(:klass_actions, klass: klass, action: :drop, previewed: previewed)
      end
    end
  end
end
