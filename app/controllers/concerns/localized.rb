module Localized
  extend ActiveSupport::Concern

  included do
    def set_timezone
      Time.zone = current_user.time_zone if current_user
    end
    
    def set_locale
      locale_in = current_account.config['allow_locale_setting_in'] || {}
      if params[:locale] && !locale_in['url_param']
        if locale_in['cookie']
          cookies.signed[:"#{current_account.slug}_locale"] = params[:locale]
        elsif locale_in['session']
          session[:"#{current_account.slug}_locale"] = params[:locale]
        end
      end

      locale_param = if locale_in['url_param']
        params[:locale]
      elsif locale_in['cookie']
        cookies.signed[:"#{current_account.slug}_locale"]
      elsif locale_in['session']
        session[:"#{current_account.slug}_locale"]
      else
        nil
      end

      I18n.locale = (
        (locale_param.present? ? locale_param : nil) ||
        (current_user && (current_user.profile.locale.present? ? current_user.profile.locale : nil)) ||
        (current_account.config['locale'].present? ? current_account.config['locale'] : nil) ||
        I18n.default_locale)
        
       prepend_view_path "app/views_overrides/#{locale}"
    end

    def default_url_options(options = {})
      locale_in = current_account.config['allow_locale_setting_in'] || {}
      localized_options = locale_in['url_param'] ? {locale: I18n.locale}.merge(options) : options
      {
        protocol: Rails.application.secrets.site['protocol']
      }.merge(localized_options)
    end 
  end

  module ClassMethods
	end
end