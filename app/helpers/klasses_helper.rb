module KlassesHelper
  def klass_menu
    enrolled = (@klass.enrolled?(current_student) || staff?(current_user, @klass.course))

    add_to_app_menu :klass, link: t("helpers.submit.main"), to: main_app.learn_klass_path(@klass), active: controller_name == 'klasses' && action_name == 'show'

    if @klass.course.config['allow_access_to']['syllabus']
      add_to_app_menu :klass, link: link_text(:page, :syllabus), to: main_app.learn_klass_page_path(@klass, @klass.course.syllabus), active: @page && @page == @klass.course.syllabus
    end

    if @klass.course.config['allow_access_to']['lectures']
      if (@klass.open? && ((@klass.allow_enrollment && enrolled) || @klass.previewed)) || (@klass.past? && @klass.lectures_on_closed)
        add_to_app_menu :klass, link: t("page.title.outline"), to: main_app.learn_klass_lectures_path(@klass), active: controller_name == 'lectures'
      end
    end

    if @klass.course.config['allow_access_to']['forums']
      if @klass.allow_enrollment && enrolled
        if @klass.open? || @klass.past?
          add_to_app_menu :klass, link: t("page.title.forums"), to: main_app.learn_klass_forums_path(@klass), active: %w(forums topics).include?(controller_name)
        end
      end
    end

    if @klass.course.config['allow_access_to']['assessments']
      if @klass.allow_enrollment && @klass.open? && enrolled
        course_assessments = @klass.course.assessments.where('unit_id is null and ready = TRUE and kind in (:kinds)',
          :kinds => @klass.course.config["grading"]["distribution"]["assessments"]["course"].keys)

        course_assessments.each_with_index do |a,i|
          if a.can_be_taken?(@klass, current_student)
            add_to_app_menu :klass, {link: a.name, to: main_app.learn_klass_assessment_path(@klass, a), active: %w(assessments attempts).include?(controller_name) && @assessment && @assessment.id == a.id}, :assessments
          end
        end
      end
    end

    if @klass.allow_enrollment && @klass.open? && enrolled
      surveys = @klass.course.assessments.
        where("unit_id is null and ready = TRUE and kind = 'survey'").
        tagged_with(:on_enroll, :exclude => true)

      surveys.each do |survey|
        if survey.can_be_taken?(@klass, current_student)
          add_to_app_menu :klass, {link: survey.name, to: main_app.new_learn_klass_assessment_attempt_path(@klass, survey)}, :surveys
        end
      end
    end

    pages = enrolled ? @klass.course.non_syllabus_pages(true).to_a : @klass.course.non_syllabus_pages(true, true).to_a
    if pages.present?
      add_to_app_menu :klass, {link: t("page.title.pages"), to: main_app.learn_klass_pages_path(@klass), active: controller_name == 'pages' && (@page.nil? || @page != @klass.course.syllabus)}, :resources
      divider = true
    end

    books = enrolled ? @klass.course.books : []
    if books.present?
      add_to_app_menu :klass, {link: t('page.title.attachments'), to: main_app.learn_klass_materials_path(@klass), active: controller_name == 'materials' }, :resources
    end
    
    if @klass.allow_enrollment && enrolled
      if @klass.course.config['allow_access_to']['reports']
        if @klass.open? || @klass.past?
          add_to_app_menu :klass, {link: t('helpers.submit.reports'), to: main_app.report_learn_klass_path(@klass), active: controller_name == 'klasses' && action_name == 'report' && params[:student_id].blank?}, :reports
        end
      end

      # if !staff?(current_user, @klass.course) && (@klass.open? || @klass.future?) && enrolled
      #   reports_links << ui_klass_enrollment_action(@klass, :drop)
      # end
    end

    if @klass && staff?(current_user, @klass.course)
      active = controller_name == 'klasses' && (action_name == 'students' || (action_name == 'report' && params[:student_id]))
      add_to_app_menu :klass, {link: t('page.title.students'), to: main_app.students_learn_klass_path(@klass), active: active}, :for_instructors

      add_to_app_menu :klass, {link: t('helpers.submit.dashboard'), to: main_app.learn_klass_dashboard_path(@klass), active: controller_name == 'dashboard'}, :for_instructors
    end
  end
  
  def klass_actions(klass, in_preview = false, right = false)
    links = []
    align = right ? :right : nil
    if klass.enrolled?(current_student) || klass.previously_enrolled?(current_student)
      #go2class or #go2class_past
      links << link(:klass, :open, main_app.learn_klass_path(klass), :class => "ui button")
    elsif klass.can_enroll?(current_user, current_student)
      if (controller_name == 'klasses' && action_name == 'show') ||
         (controller_name == 'lectures' && action_name == 'index') || @lecture
        # Enrollment links
        if klass.dropped?(current_student)
          #enroll again
          links << (capture do
            content_tag(:p, t('page.text.free_to_enroll_again')) +
            link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass),
              :class => "ui primary button")
          end)
        elsif !klass.private || klass.invited_and_not_yet_accepted?(current_user)
          if !in_preview && klass.previewed
            #preview
            links << (capture do
              content_tag(:p, t('page.text.free_to_preview')) +
              link(:enrollment, :open,  main_app.learn_klass_lectures_path(klass),
                  :class => "ui button")
            end)
          else
            #enroll
            links << (capture do
              (!in_preview ? content_tag(:p, t('page.text.free_to_enroll')) : ''.html_safe) +
              link(:enrollment, :enroll, main_app.enroll_learn_klass_path(klass),
                :class => "ui primary button")
            end)
          end
        end

        mountable_fragments(:klass_enrollment_actions, klass: klass, action: :enroll, previewed: in_preview, links: links, right: right)

        if klass.invited_and_not_yet_accepted?(current_user)
          #decline
          links << link(:enrollment, :decline, main_app.decline_learn_klass_path(klass),
                      :class => "ui negative button", :method => :put)
        end

        # if !in_preview && klass.previewed
        #   #preview
        #   links << link(:enrollment, :preview,  main_app.learn_klass_lectures_path(klass),
        #       :class => "ui button")
        # end
      else
        #learn_more
        links << link(:klass, :learn_more, learn_klass_path(klass), :class => "ui button")
        mountable_fragments(:klass_flags_actions, klass: klass, previewed: in_preview, links: links, right: right)
      end
    elsif current_user && staff?(current_user, klass)
      #admin or faculty
      links << link(:klass, :open, main_app.teach_course_klass_path(klass.course, klass), :class => "ui button")
    end

    links.join(' ').html_safe
  end

  def ui_klass_enrollment_action(klass, action, previewed = false, right = false)
    if action == :enroll
      klass_actions(klass, previewed, right)
    else
      link(:klass, :drop, main_app.drop_learn_klass_path(@klass), method: :put, confirm: true, class: 'item')
    end
  end

  def klass_availability(klass)
    days = (Date.current - klass.begins_on).to_i
    starts_in = if days == 0
      t('page.text.today')
    elsif days < 0
      t('page.text.in_days', :count =>  -1 * days)
    elsif days > 0
      past = klass.ends_on ? (Date.current - klass.ends_on) : nil
      if past == nil || past <= 0
        t('page.text.open_for_enrollment')
      else
        t('page.text.closed')
      end
    end
  end
end
