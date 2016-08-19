module UsersHelper
  def user_menu
    add_to_app_menu(:user, link(:user, :change_password, main_app.edit_auth_registration_path(current_user)))
    add_to_app_menu(:user, link(:profile, :edit_profile, main_app.edit_user_path(current_user)))
    
    if current_user.has_role? :blogger
      add_to_app_menu(:user, link(:page, :blog_posts, main_app.pages_path))
    end

    if current_account.config['allow_user_student_dependents']
      add_to_app_menu(:user, link(:student, :index,  main_app.learn_students_path),
        Student.model_name.human(count: 3))
    end

    if current_account.config['allow_faculty_applications']
      if !current_user.has_role?(:admin) && !current_user.has_role?(:faculty)
        section = t('page.title.get_involved')
        faculty_application = FacultyApplication.approved_or_pending(current_user).first
        if faculty_application
          if faculty_application.pending?
            add_to_app_menu(:user, link(:faculty_application, :become_a_faculty, main_app.edit_faculty_application_path(faculty_application)), section)
          end
        else
          add_to_app_menu(:user, link(:faculty_application, :become_a_faculty, main_app.new_faculty_application_path), section)
        end
      end
    end
    
    if current_user.has_role?(:admin) || current_user.has_role?(:faculty)
      add_to_app_menu(:user, link(:course, :start_new_course, main_app.new_teach_course_path), :teach)
    end
    
    if current_user.has_role? :admin
      section = :administration

      add_to_app_menu(:user, link_to(t('page.title.dashboard'), admin_dashboard_path), section)

      if current_user.id == 1
        add_to_app_menu(:user, link(:account, :index,  main_app.admin_accounts_path), section)
        # if Rails.application.secrets.redis_enabled
        #   add_to_app_menu(:user, link_to(:Sidekiq, main_app.sidekiq_web_path, target: '_new'), section)
        # end
      end

      add_to_app_menu(:user, [
        link(:user, :index, main_app.users_path), 
        link(:page, :index, main_app.pages_path), 
        link(:medium, :index, main_app.media_path), 
        link(:announcement, :index,  main_app.admin_announcements_path)], section)

      section = :settings
      if current_user.id == 1
        add_to_app_menu(:user, link(:configuration, :site_settings,  main_app.admin_config_edit_path), section)
      end
      if current_user.id == current_account.user_id
        add_to_app_menu(:user, link(:account, :account_settings,  main_app.edit_admin_account_path(current_account)), section)
      end

      if Rails.application.secrets.redis_enabled
        add_to_app_menu(:user, link(:translation, :index,  main_app.edit_admin_translation_path(I18n.locale)), section)
      end
    end

    mountable_fragments :user_menu
  end
end
