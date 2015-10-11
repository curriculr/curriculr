module ApplicationHelper
  FLASH_MSG_TYPES = {
    alert: :error,
    error: :error,
    notice: :success,
    success: :success,
    error: :error,
    info: :info
  }

  def title
    title = t("#{current_account.slug}.site.title", :default => current_account.config['title'] || $site['title'])
    title.html_safe if title.present?
  end

  def rtl?
    # To be expanded later
    locale == :ar
  end

  def scoped_t(*args)
    key, params =  *args
    params = {} if params.blank?
    params[:default] = t(key.sub(/^[^\.]*\./, 'account.'), params)

    t(key, params)
  end

  def link(model, action, options = nil, html_options = nil)
    link_text = case action
    when :index
      t("activerecord.models.#{model}.other")
    when :new, :create, :edit, :update, :destroy
      t(action, scope: 'activerecord.actions', :name => t("activerecord.models.#{model}.one", :default => ''))
    else
      key = (html_options.present? && html_options[:as].present?) ? "#{action}_#{html_options[:as]}" : action

      t(key, scope: 'activerecord.actions')
    end

    if html_options.present? and (confirm = html_options[:confirm]) and confirm.present? and confirm == true
      confirmation = t(action, scope: 'activerecord.confirmations', :name => t("activerecord.models.#{model}.one"))

      link = ''

      default = html_options[:as].present? ? html_options[:as].to_sym : action.to_sym
      custom_html_options = html_options.reject{|k,v| %w(data confirm as class).include? (k.to_s) }
      custom_html_options[:class] = css_button(:danger)
      link = link_to(link_text.html_safe, options, custom_html_options)

      return link_to(link_text.html_safe, '#', :class => html_options[:class],
                :onclick => "ui_modal_confirmation('page', '#{t('page.titles.hold_on')}', '#{confirmation}', '#{j link}', '#{t('activerecord.actions.close')}' )")
    end

    link_to(link_text.html_safe, options, html_options)
  end

  def pnotify_script_tag
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank? || %w(part data).include?(type.to_s)

      flash_messages << %(
        var the_stack = {"dir1": "down", "dir2": "#{rtl? ? 'right' : 'left'}", "firstpos1": 50, "firstpos2": 25};
        var notice = new PNotify({
            title: false,
            text: '#{message}',
            width: '350px',
            type: '#{FLASH_MSG_TYPES[type.to_sym]}',
            delay: 2000,
            styling: 'fontawesome',
            buttons: {
              closer: true,
              sticker: false
            },
            stack: the_stack
        });

        notice.get().click(function() {
            notice.remove();
        });
      )
    end

    javascript_tag flash_messages.join("\n").html_safe

  end

  def klass_from_and_to_dates(klass)
    text = l(klass.begins_on)
    if klass.ends_on
      text << ' - '
      text << l(klass.ends_on)
    end

    text
  end

  def ui_breadcrumbs(links, here = t('page.text.here'))
    content_tag :ul, class: css_breadcrumb do
      html = ''
      links.each do |link|
        html << content_tag(:li, link_to(link[:name], link[:href]))
      end

      html << content_tag(:li, here) if here
      html.html_safe
    end
  end

  def ui_audio(audio, options={})
    config = { controls: "control", preload: "none", width: "100%", class: 'mediaelementjs' }

    medium = audio.is_a?(Material) ? audio.medium : audio
    content_type =  if medium.content_type == 'link/www'
      ext = File.extname(audio.at_url)
      if ext.present?
        "audio/#{ext[1..-1]}"
      else
        'audio/mp3'
      end
    else
      medium.content_type
    end
    content_tag :div, class: "audio-container #{options[:class]}" do
      content_tag :audio, config.merge(options.reject{|k,v| k == :class}) do
        content_tag :source, '', src: audio.at_url, type: content_type
      end
    end
  end

  def ui_video(video, poster = nil, options={})
    @req_attributes[:video?] = true

    if $site['sublimevideo_site_token'].present?
      render :partial => "ui_video_sublime",
        :locals => {
          video: video, poster: poster, thumbnail: options[:thumbnail], style_class: options[:class],
          title: '', width: options[:width], height: options[:height], autoplay: options[:autoplay]
        }
    else
      render :partial => "ui_video_mediaelement",
        :locals => {
          video: video, poster: poster, thumbnail: options[:thumbnail], style_class: options[:class],
          title: '', width: options[:width], height: options[:height], autoplay: options[:autoplay]
        }
    end
  end

  def ui_document_viewer(url)
    viewer = "https://docs.google.com/viewer"
    params = {
      :url => asset_url(url),
      :embedded => true
    }

    html = ( content_tag :small do
      t('page.text.document_noshow_html', link: link_to(t('activerecord.actions.open'), url, class: css_button, target: '_new'))
    end )

    html << content_tag(:iframe, '', src: "#{viewer}?#{params.to_query}", width: "100%", height: "780", style: "border: none;")

    html
  end

  def to_medium_kind(kind)
    return :video unless kind

    case kind.to_sym
    when :poster
      :image
    when :videos
      :video
    when :slides
      :document
    when :notes
      :document
    when :books
      :document
    when :data
      :other
    else
      kind.to_sym
    end
  end
end
