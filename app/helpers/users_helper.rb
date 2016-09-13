module UsersHelper
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

    if current_account.config['allow_faculty_applications']
      if !current_user.has_role?(:admin) && !current_user.has_role?(:faculty)
        faculty_application = FacultyApplication.approved_or_pending(current_user).first
        if faculty_application 
          if faculty_application.pending?
            add_to_app_menu(:user, {link: link_text(:faculty_application, :become_a_faculty), to: main_app.edit_faculty_application_path(faculty_application), remote: true, active: controller_name == 'faculty_applications' && action_name.in?(['new', 'create'])}, :teaching)
          end
        else
          add_to_app_menu(:user, {link: link_text(:faculty_application, :become_a_faculty), to: main_app.new_faculty_application_path, remote: true, active: controller_name == 'faculty_applications' && action_name.in?(['new', 'create'])}, :teaching)
        end
      end
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

      #add_to_app_menu(:user, {link: t('page.title.dashboard'), to: admin_dashboard_path, active: controller_name == 'dashboard'}, section)

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
end
