module UiHelper
  def space_tag(count = 1, options = {})
    if options.present?
      content_tag :i, (%(&nbsp;) * count).html_safe, options
    else
      (%(&nbsp;) * count).html_safe
    end
  end

  def flag_tag(country, show_name = true)
    return nil if country.blank?

    html = content_tag(:i, '', :class => "#{country.downcase} flag")
    html << Country.new(country).name
    html.html_safe
  end

  # Social Links
  def ui_facebook_link(object)
    case object
    when Klass
      klass = object
      caption = ""
      if klass
        l(klass.begins_on)
        caption << " - #{l(klass.ends_on)}" if klass.ends_on.present?
      end

      options = {
        :app_id => Rails.application.secrets.auth['facebook']['id'],
        :link => URI.join(main_app.root_url, main_app.learn_klass_path(klass)),
        :picture => URI.join(main_app.root_url, ui_image_src(klass.course.poster ? klass.course.poster.at_url(:md) : nil, '/images/holder-md.png')),
        :name => klass.course.name,
        :caption => caption,
        :description => ui_social_message(klass),
        :redirect_uri => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
      }

      link_to "https://www.facebook.com/dialog/feed?#{options.to_query}", class: css_button(:facebook) do
        %(#{content_tag(:i, "", :class => "fa fa-facebook fa-lg")}
        ).html_safe
      end
    when Page
      page = object
      html = ''
      if page && page.public && page.blog && page.published
        options = { appId: Rails.application.secrets.auth['facebook']['id'], href: page_url(page) }

        html = %(<iframe src="//www.facebook.com/plugins/like.php?#{options.to_query}&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=true&amp;share=true&amp;height=80" scrolling="no" frameborder="0" style="border:none; overflow:hidden; height:80px;" allowTransparency="true"></iframe>)
      end

      html.html_safe
    else
      ''
    end
  end

  def ui_twitter_link(klass)
    options = {
      :text => ui_social_message(klass),
      :hashtags => klass.course.name,
      :url => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
    }

    link_to "https://twitter.com/share?#{options.to_query}", class: css_button(:twitter) do
      %(#{content_tag(:i, "", :class => "fa fa-twitter fa-lg")}
      ).html_safe
    end
  end

  def ui_google_plus_link(klass)
    options = {
      :url => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
    }

    link_to "https://plus.google.com/share?#{options.to_query}", class: css_button(:google) do
      %(#{content_tag(:i, "", :class => "fa fa-google-plus fa-lg")}
      ).html_safe
    end
  end

  private
    def ui_social_message(klass)
      if current_user
        if staff?(current_user, klass.course)
          if klass.open?
            msg = t('page.text.social_teaching')
          elsif klass.past?
            msg = t('page.text.social_taught')
          else
            msg = t('page.text.social_will_teach')
          end
        elsif klass.enrolled?(current_student)
          if klass.open?
            msg = t('page.text.social_taking')
          elsif klass.past?
            msg = t('page.text.social_took')
          else
            msg = t('page.text.social_will_take')
          end
        end
      else
        msg = t('page.text.social_interested')
      end
    end
end
