# For ui components: css, html, and js
module UiComponentsHelper
  ALERT_TYPES = [:error, :info, :success, :warning]

  def flag_tag(country, show_name = true)
    return nil if country.blank?

    html = content_tag(:i, '', :class => "#{country.downcase} flag")
    html << ' ' << Country.new(country).name
    html.html_safe
  end

  def ui_flag(country)
    content_tag :i, '', class: "#{country.downcase} flag"
  end
  
  def ui_icon(name)
    content_tag :i, '', class: "#{name} icon"
  end
  
  def ui_icon_for(name)
    case name.to_s
    when 'video'
      ui_icon('file video outline')
    when 'audio'
      ui_icon('file audio outline')
    when 'image'
      ui_icon('file image outline')
    when 'document'
      ui_icon('file pdr outline')
    when 'other'
      ui_icon('file code outline')
    when 'question'
      ui_icon('help')
    when 'page'
      ui_icon('world')
    when 'lecture'
      ui_icon('book')
    when 'assessment'
       ui_icon('lab')
    when 'attachement'
      ui_icon('attach')
    end
  end
  
  def ui_header(text, options = {})
    options[:style] ||= :h2
    right = ''
    left = (content_tag options[:style], class: "ui #{'left floated ' if options[:action]}#{'dividing ' if options[:dividing]}header" do
      hdr = text
      hdr << content_tag(:div, options[:subtext], class: 'sub header') if options[:subtext].present?
      
      hdr.html_safe
    end)
    
    if options[:action]
      right = content_tag(:div, options[:action].html_safe, class: 'ui right floated header') if options[:action].present?
      content_tag(:div, left + right, class: 'page clearing header')
    else
      left
    end
  end

  def ui_side_by_side(side_a, side_b, config = 'twelve by four')
    sizes = config.split('by').map{|s| s.strip}
    content_tag :div, class: "ui grid" do
      html = ''
      html << content_tag(:div, side_a, class: "#{sizes[0]} wide column") unless sizes[0] == 'zero'
      html << content_tag(:div, side_b, class: "#{sizes[1]} wide column") unless sizes[1] == 'zero'

      html.html_safe
    end
  end
  
  def staff_or_student_view(default_action = nil)
    if @course && !@course.id.nil? && staff?(current_user, @course)
      klass = (@klass || @course.klasses.last)
      if klass && !klass.new_record?
        link_to learn_klass_path(klass), class: 'ui secondary button' do
          ui_icon(:student) + ' ' + t('helpers.submit.show_student_view')
        end
      end
    elsif @klass && staff?(current_user, @klass.course)
      link_to teach_course_klass_path(@klass.course, @klass), class: 'ui secondary button' do
        ui_icon(:doctor) + ' ' + t('helpers.submit.show_instructor_view')
      end
    else
      action = ''
      action << ui_buttons([default_action]) if default_action.present?
      action.html_safe
    end
  end

  def ui_buttons(buttons, options = {})
    content_tag :div, class: "ui #{options[:class]} buttons" do
      html = ''
      buttons.each do |button|
        html << button unless button.nil?
      end
      html.html_safe
    end
  end
  
  def ui_dropdown_button(text, links, options = {class: 'ui dropdown primary button'})
    content_tag :div, class: (options[:class] || 'ui dropdown primary button') do
      html = ''
      html << content_tag(:span, text, class: 'text') unless text.blank?
      html << (options[:icon] || ui_icon('dropdown'))
      html << content_tag(:div, links.join("\n").html_safe, class: 'menu')
      
      html.html_safe
    end
  end
  
  def ui_flash_messages
    output = ''
    flash.each do |type, message|
      next if message.blank?
      type = :success if type.to_sym == :notice
      type = :error   if type.to_sym == :alert
      next unless ALERT_TYPES.include?(type.to_sym)
      output += (
        content_tag(:div, class: "ui #{type} message page.clearing.header") do
          content_tag(:i, '', class: "close icon") + message
        end
      )
    end

    raw(output)
  end
  
  def ui_audio(audio, options={})
    config = { controls: "control", preload: "none" }

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

  def ui_video(video, poster = nil, options={autoplay: false})
    @req_attributes[:video?] = true

    if video.medium.content_type == 'link/youtube'
      render :partial => "ui_video_youtube",
        :locals => {
          video: video, poster: poster, thumbnail: options[:thumbnail], style_class: options[:class],
          title: '', width: options[:width], height: options[:height], autoplay: options[:autoplay]
        }
    else
      render :partial => "ui_video_videojs",
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
  
  # Social Links
  def ui_facebook_link(object, text = nil)
    case object
    when Klass
      klass = object
      caption = ""
      if klass
        caption << klass_from_and_to_dates(klass)
      end

      options = {
        :app_id => Rails.application.secrets.auth['facebook']['id'],
        :link => URI.join(main_app.root_url, main_app.learn_klass_path(klass)),
        :picture => URI.join(main_app.root_url, (klass.course.poster&.at_url(:md) || '/images/holder-md.png')),
        :name => klass.course.name,
        :caption => caption,
        :description => ui_social_message(klass),
        :redirect_uri => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
      }

      link_to "https://www.facebook.com/dialog/feed?#{options.to_query}", class: 'ui circular facebook icon button' do
        ui_icon(:facebook) + ' ' + text
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

  def ui_twitter_link(klass, text = nil)
    options = {
      :text => ui_social_message(klass),
      :hashtags => klass.course.name,
      :url => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
    }

    link_to "https://twitter.com/share?#{options.to_query}", class: 'ui circular twitter icon button' do
      ui_icon(:twitter) + ' ' + text
    end
  end

  def ui_google_plus_link(klass, text = nil)
    options = {
      :url => URI.join(main_app.root_url, main_app.learn_klass_path(klass))
    }

    link_to "https://plus.google.com/share?#{options.to_query}", class: 'ui circular google plus icon button' do
      ui_icon("google plus") + ' ' + text
    end
  end

  private
    def ui_social_message(klass)
      if current_user
        if staff?(current_user, klass.course)
          if klass.open?
            t('page.text.social_teaching')
          elsif klass.past?
            t('page.text.social_taught')
          else
            t('page.text.social_will_teach')
          end
        elsif klass.enrolled?(current_student)
          if klass.open?
            t('page.text.social_taking')
          elsif klass.past?
            t('page.text.social_took')
          else
            t('page.text.social_will_take')
          end
        else
          t('page.text.social_interested')
        end
      else
        t('page.text.social_interested')
      end
    end
end