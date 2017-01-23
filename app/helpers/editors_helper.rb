module EditorsHelper
  MARKDOWN_SUMMARY_DELIMITER = "~------\r?\n"

  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      begin
        Pygments.highlight(code, lexer: language)
      rescue MentosError
        Pygments.highlight(code, lexer: 'text')
      end
    end
  end

  markdown = Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
  # Markdown Text

  def markdown(text, options = {})
    return text.html_safe if options[:html] && options[:html] == true

    renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer,
      :no_intra_emphasis => true,
      :tables => true,
      :fenced_code_blocks => true,
      :autolink => false,
      :disable_indented_code_blocks => true,
      :strikethrough => true,
      :lax_spacing => true,
      :space_after_headers => true,
      :superscript => true,
      :underline => true,
      :highlight => true,
      :quote => true,
      :footnotes => true
    )

    text.sub!(/#{MARKDOWN_SUMMARY_DELIMITER}/i, "\n") if text.present?

    #preprocess math
    text = '' if text.nil?
    math_formulae = text.scan(/(\\\([\S|\s]+?\\\)+?)|(\\\[[\S|\s]+?\\\]+?)/).flatten.reject {|m| m.nil?}
    math_formulae.each_with_index {|m,i| text.sub!(m,"{{{{#{i}}}}}")}

    text = markdown.render(text || '')
    text.gsub! /\[([^\[\]]*)\]/ do |m|
      post_process m
    end

    text.gsub! /\<code\>.+?\<\/code\>/ do |m|
      post_process m
    end

    math_formulae.each_with_index {|m,i| text.sub!("{{{{#{i}}}}}", m)}
    if math_formulae.present?
      @req_attributes[:math?] = true
    end

    %(<div class="#{"markdown-output #{options[:class] if options} #{"hidden-til-processed" if options && options[:hidden_til_processed]}"}">
      #{text}
    </div>).html_safe
    #content_tag :div, text.html_safe, class: "markdown-output #{options[:class] if options} #{"hidden-til-processed" if options and options[:hidden_til_processed]}"
  end

  def processed_text(text)
    text.gsub! /\[([^\[\]]*)\]/ do |m|
      post_process m
    end

    text.gsub! /\<code\>.+?\<\/code\>/ do |m|
      post_process m
    end

    text.html_safe
  end

  def post_process(text)
    if text =~ /\[math\:(.*)\]/
      "<img src='#{$1}'>".html_safe
    elsif text =~ /\[video\:(.*)\]/
      %(<video width="100%" height="100%" preload="none" class="mediaelementjs" controls>
          <source src='#{$1}'/>
        </video>).html_safe
    elsif text =~ /\[youtube\:(.*)\]/
      %(<div class="video-container-yt">
      <iframe type="text/html" width="640" height="390"
        src="//www.youtube.com/embed/#{$1}?controls=1&wmode=transparent&rel=0&showinfo=0&enablejsapi=1&modestbranding=1&html5=1&origin=<%= root_url %>"
        frameborder="0"></iframe>
      </div>).html_safe
    elsif text =~ /\[audio\:(.*)\]/
      %(<audio controls preload="none" width="100%" class="mediaelementjs">
          <source src="#{$1}"/>
        </audio>).html_safe
    elsif text =~ /\[iframe\:(.*)\]/
      "<iframe scrolling='yes' border='0' frameborder='0' width='100%' src='#{$1}'></iframe>".html_safe
    elsif text =~ /\[pron\:(.*)\]/
      %(<span class="pronounce-able">
        <audio src="#{$1}"></audio>
        <i class="volume up icon"></i>
      </span>).html_safe
    elsif text =~ /\[ext\:([^\:]*)\:([^\|]*)(\|(.*))?\]/
      data = {'id' => $2}
      if $4
        $4.split('|').each do |p|
          t = p.split('=')
          data[t.first] = t.last if t.size == 2
        end
      end
      content_tag :div, '', class: "#{$1}-able", data: data
    elsif text =~ /\<code\>(.+?)\<\/code\>/
      body = $1
      if body =~ /\$\$(.*)\$\$/
        "$$ #{$1} $$"
      elsif body =~ /\$(.*)\$/
        "$ #{$1} $"
      else
        "<code>#{body}</code>".html_safe
      end
    end
  end

  def markdown_textarea (form, model, field, options = {})
    output ||= %(<div class="input">)
    # if options[:label]
    #   label ||= options[:label]
    #   unless !label.nil? && !!label == label
    #     output += form.label field
    #   end
    # end

    options[:data] ||= field.to_s
    wmd_id = options[:data] #? options[:data]: ''

    output += %(
    <div class="wmd-panel">
      <div id="wmd-button-bar#{wmd_id}"></div>)

    ta_options = { size: '60x10', class: 'wmd-input', id: "wmd-input#{wmd_id}" }
    options.map do |k,v|
      if k == :class
        ta_options[k] = ta_options[k].present? ? "#{ta_options[k]} #{v}" : v
      else
        ta_options[k] = v
      end
    end

    output += form.text_area field, ta_options
    output += "</div>"

    output += %(
      <div id="wmd-preview#{wmd_id}" class="wmd-panel wmd-preview well"></div>
    ) if options.include?(:preview) && options[:preview]

    output += "</div>"
    output.html_safe
  end

  def summary(text, length = 200)
    if text
      delimiter = MARKDOWN_SUMMARY_DELIMITER
      if text =~ /#{delimiter}/i
        text = text.split(/#{delimiter}/i).first.strip
      end

      excerpt(text, text[1..50],  radius: length)
    end
  end

  # Ace Editor
  def highlighted_code(text, lang, input=nil)
    @req_attributes[:code?] = true
    lines_count = [[ text.lines.count, 25 ].max, 40].min
    options = {
      :class => "ace-editor",
      :style => "height: #{lines_count * 16}px;",
      :data => {
        :mode => lang,
        :theme => ($site['ace_code_editor_style'] || 'twilight'),
        :readonly => input.blank?,
        :input => (input || '')
      }
    }

    content_tag :div, text, options
  end
end
