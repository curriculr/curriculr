module MenuHelper
  def main_menu
    add_to_app_menu :top, link: t('page.title.dashboard'), to: main_app.home_path, active: (action_name =='home' && controller_name == 'users') if current_user

    add_to_app_menu :top, link: link_text(:klass, :learn), to: main_app.learn_klasses_path, active: @course.blank? && (controller_name == 'klasses' || @klass.present?)

    if current_user && (current_user.has_role?(:admin) || current_user.has_role?(:faculty))
      add_to_app_menu :top, link: link_text(:course, :teach), to: main_app.teach_courses_path, active: controller_name == 'courses' || @course.present?
    end

    add_to_app_menu :top, link: link_text(:page, :blogs), to: main_app.blogs_path, active: controller_name == 'pages' && action_name == 'blogs'
    
    locale_in = current_account.config['allow_locale_setting_in'] || {}
    if locale_in['url_param'] || locale_in['cookie'] || locale_in['session']
      add_to_app_menu :top, $site['supported_locales'][I18n.locale.to_s], :locale
      
      $site['supported_locales'].each do |k,v|
        if k == I18n.locale.to_s
          add_to_app_menu :top, {link: v, to: '#', active: false}, :locale
        else
          add_to_app_menu :top, {link: v, to: url_for(locale: k)}, :locale
        end
      end
    end

    unless current_user
      unless request.path.ends_with?('/signin')  || request.path.ends_with?('/signup')
        add_to_app_menu :top, {link: link_text(:user, :signin), to: main_app.auth_signin_path}, :right
      end
    else
      add_to_app_menu :top, {link: link_text(:session, :sign_out), to: main_app.auth_signout_path}, :right
    end
    
    mountable_fragments :main_menu
  end
  
  def footer_menu
    add_to_app_menu :bottom, [
      "© #{t('page.text.copyrights', :year => Time.zone.now.year)}",
      {link: link_text('miscellaneous', :about), to: main_app.localized_page_path(:about)},
      {link: link_text('miscellaneous', :contactus), to: main_app.contactus_path, remote: true},
      {link: link_text(:page, :terms), to: main_app.localized_page_path(:terms)} ]
      
      mountable_fragments :footer_menu
  end
  
  def user_menu
    return unless current_user
    
    add_to_app_menu :user, link: link_text(:user, :change_password), to: main_app.edit_auth_registration_path(current_user), remote: true, active: controller_name == 'registrations' && action_name.in?(['edit', 'update'])
    add_to_app_menu :user, link: link_text(:profile, :edit_profile), to: main_app.edit_user_path(current_user), remote: true, active: controller_name == 'users' && action_name.in?(['edit', 'update'])
    
    if current_user.has_role?(:blogger) && !current_user.has_role?(:admin) 
      add_to_app_menu :user, link: link_text(:page, :blog_posts), to: main_app.pages_path, active: controller_name == 'pages'
    end

    if current_account.config['allow_user_student_dependents']
      add_to_app_menu :user, link: link_text(:student, :index), to: main_app.learn_students_path, active: controller_name == 'students' && action_name == 'index'
    end
    
    if current_user.has_role?(:admin) || current_user.has_role?(:faculty)
      add_to_app_menu(:user, {link: link_text(:course, :index), to: main_app.teach_courses_path, active: controller_name == 'courses' && action_name.in?(['index'])}, :teaching)
    end
    
    add_to_app_menu(:user, [
      {link: t('page.title.available_klasses'), to: main_app.learn_klasses_path, active: controller_name == 'klasses' && params[:s].nil?},
      {link: t('page.title.taking_klasses'), to: main_app.learn_klasses_path(:s => :taking), active: controller_name == 'klasses' && params[:s] == 'taking'},
      {link: t('page.title.enrolled_klasses'), to: main_app.learn_klasses_path(:s => :enrolled), active: controller_name == 'klasses' && params[:s] == 'enrolled'},
      {link: t('page.title.taken_klasses'), to: main_app.learn_klasses_path(:s => :taken), active: controller_name == 'klasses' && params[:s] == 'taken'}], :learning)
    
    if current_user.has_role? :admin
      section = :administration

      if current_user.id == 1
        add_to_app_menu(:user, {link: link_text(:account, :index), to: main_app.admin_accounts_path, active: controller_name == 'accounts'}, section)
        # if Rails.application.secrets.redis_enabled
        #   add_to_app_menu(:user, link_to(:Sidekiq, main_app.sidekiq_web_path, target: '_new'), section)
        # end
      end

      add_to_app_menu(:user, [
        {link: link_text(:user, :index), to: main_app.users_path, active: controller_name == 'users' && action_name != 'home'}, 
        {link: link_text(:page, :index), to: main_app.pages_path, active: controller_name == 'pages' && action_name == 'index'}, 
        {link: link_text(:medium, :index), to: main_app.media_path, active: controller_name == 'media'}, 
        {link: link_text(:announcement, :index), to: main_app.admin_announcements_path, active: controller_name == 'announcements'}], section)

      section = :settings
      if current_user.id == 1
        add_to_app_menu(:user, {link: link_text(:configuration, :site_settings), to: main_app.admin_config_edit_path, active: controller_name == 'config' && action_name == 'edit'}, section)
      end
      if current_user.id == current_account.user_id
        add_to_app_menu(:user, {link: link_text(:account, :account_settings), to: main_app.settings_admin_account_path(current_account), active: controller_name == 'accounts' && action_name.in?(['edit', 'update'])}, section)
      end

      # if Rails.application.secrets.redis_enabled
      #   add_to_app_menu(:user, {link: link_text(:translation, :index), to: main_app.edit_admin_translation_path(I18n.locale || :en), active: controller_name == 'translations' && action_name == 'edit'}, section)
      # end
    end

    mountable_fragments :user_menu
  end
  
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
  
  def klass_menu
    add_to_app_menu :klass, link: t("helpers.submit.main"), to: main_app.learn_klass_path(@klass), active: controller_name == 'klasses' && action_name == 'show'

    if @klass.course.config['allow_access_to']['lectures']
      if (@klass.open? && ((@klass.allow_enrollment && enrolled_or_staff?) || @klass.previewed)) || (@klass.past? && @klass.lectures_on_closed)
        lectures, active_unit_id, active_lecture_id = Lecture.listing_for_student(@klass, current_student).to_a
        if lectures.any?
          add_to_app_menu :klass, link: t("page.title.outline"), to: main_app.learn_klass_lectures_path(@klass), active: controller_name == 'lectures'
        end
      end
    end

    if @klass.course.config['allow_access_to']['forums']
      if @klass.allow_enrollment && enrolled_or_staff?
        if @klass.open? || @klass.past?
          add_to_app_menu :klass, link: t("page.title.discussion"), to: main_app.learn_klass_forums_path(@klass), active: %w(forums topics).include?(controller_name)
        end
      end
    end

    if @klass.course.config['allow_access_to']['assessments']
      if @klass.allow_enrollment && @klass.open? && enrolled_or_staff?
          add_to_app_menu :klass, {link: Assessment.model_name.human(count: 3), to: main_app.learn_klass_assessments_path(@klass), active: %w(assessments attempts).include?(controller_name)}, :assessments if @klass.assessments.any?
      end
    end

    if @klass.allow_enrollment && @klass.open? && enrolled_or_staff?
      surveys = @klass.course.assessments.
        where("unit_id is null and ready = TRUE and kind = 'survey'").
        tagged_with(:on_enroll, :exclude => true)

      surveys.each do |survey|
        if survey.can_be_taken?(@klass, current_student)
          add_to_app_menu :klass, {link: survey.name, to: main_app.new_learn_klass_assessment_attempt_path(@klass, survey)}, :surveys
        end
      end
    end
    
    add_to_app_menu :klass, {link: t("page.title.reading"), to: main_app.learn_klass_pages_path(@klass), active: controller_name == 'pages' && (@page.nil? || @page != @klass.course.syllabus)}, :resources
      divider = true

    if @klass.allow_enrollment && enrolled_or_staff?
      active = controller_name == 'klasses' && (action_name == 'students' || (action_name == 'report'))
      if staff?(current_user, @klass.course)
        add_to_app_menu :klass, {link: t('page.title.progress'), to: main_app.students_learn_klass_path(@klass), active: active}, :reports
      else
        if @klass.course.config['allow_access_to']['reports']
          if @klass.open? || @klass.past?
            add_to_app_menu :klass, {link: t('page.title.progress'), to: main_app.report_learn_klass_path(@klass), active: active}, :reports
          end
        end
      end
    end
  end
end
