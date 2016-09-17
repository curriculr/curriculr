module ApplicationHelper
  FLASH_MSG_TYPES = {
    alert: :error,
    error: :error,
    notice: :success,
    success: :success,
    error: :error,
    info: :info
  }
  
  def logo_path(inverted = false)
    logo = current_account.config['theme']['logo'].present? ? "/images/logo.png" : false
    logo = logo.sub(/\.png$/, "-inverted.png") if inverted
    logo
  end

  def footer_menu
    add_to_app_menu :bottom, [
      "© #{t('page.text.copyrights', :year => Time.zone.now.year)}",
      {link: link_text('miscellaneous', :about), to: main_app.localized_page_path(:about)},
      {link: link_text('miscellaneous', :contactus), to: main_app.contactus_path, remote: true},
      {link: link_text(:page, :terms), to: main_app.localized_page_path(:terms)} ]
      
      mountable_fragments :footer_menu
  end
  
  def main_menu
    if current_user
      add_to_app_menu :top, link: ui_icon('large home'), to: main_app.home_path, active: action_name =='home' && controller_name == 'users'
    end
    
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
      avatar = image_tag(current_user.profile.avatar_url(current_account, :tny) || '/images/nobody-tny.png', class: 'avatar icon')
      add_to_app_menu :top, {link: avatar + link_text(:session, :sign_out), to: main_app.auth_signout_path, class: "labeled icon"}, :right
    end
    
    mountable_fragments :main_menu
  end
  
  def true?(val)
    !val.nil? && val == true
  end

  def false?(val)
    !val.nil? && val == false
  end
  
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
  
  def link_text(model, action, options = {})
    text = case action
    when :index
      t("activerecord.models.#{model}.other")
    when :new, :create, :edit, :update, :destroy
      t(action, scope: 'helpers.submit', :name => '')
    else
      key = (options.present? && options[:as].present?) ? "#{action}_#{options[:as]}" : action

      t(key, scope: 'helpers.submit')
    end
    
    text.html_safe
  end
  
  def link(model, action, path = nil, options = {})
    text = link_text(model, action, options)

    if options.present? && (confirm = options[:confirm]) && confirm.present? && confirm == true
      confirmation = t(action, scope: 'helpers.confirmation', :name => t("activerecord.models.#{model}.one"))

      default = options[:as].present? ? options[:as].to_sym : action.to_sym
      custom_options = options.reject{|k,v| %w(data confirm as).include? (k.to_s) }
      link = link_to(text, path, custom_options)


      return link_to(text, '#', class: "#{options[:class]} confirm-first", data: {
        header: t('page.title.hold_on'), content: confirmation, action: link, cancel: t('helpers.submit.close')})
    end
    
    link_to(text, path, options)
  end

  def pnotify_script_tag
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages.
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
    content_tag :div, class: 'ui breadcrumb' do
      (links.map{|link| link_to(link[:name], link[:href], class: 'section')} << content_tag(:div, here, class: 'active section')).join(ui_icon('right angle icon divider')).html_safe
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
      t('page.text.document_noshow_html', link: link_to(t('helpers.submit.open'), url, target: '_new'))
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
