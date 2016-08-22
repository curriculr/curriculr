# For ui components: css, html, and js
module Themes::Bootstrap::UiComponentsHelper
  def ui_klass_labels(klass, wrapped = false)
    labels = ui_course_labels(klass.course)
    if klass.private
      labels << content_tag(:div, Klass.human_attribute_name(:private), :class => :item)
    end

    labels << mountable_fragments(:klass_attributes_actions, :klass => klass, :lables => labels)

    wrapped ? content_tag(:div, labels.join("\n").html_safe, :class => "ui big horizontal list") : labels
  end

  def ui_course_labels(course, wrapped = false)
    labels = []
    unless course.country.blank?
      labels << content_tag(:div, flag_tag(course.country), :class => :item)
    end

    Translator.to_hash(I18n.locale, "#{current_account.slug}.site.level.*").each_with_index do |l, i|
      if Course.scoped.tagged_with(l.first, :on => :levels).to_a.include? course
        html = ''
        (1..i).each { html << content_tag(:i, '', class: 'fa fa-circle') } if i > 0
        ((i+1)..3).each { html << content_tag(:i, '', class: 'fa fa-circle-o') }
        html << "&nbsp;" << l.second

        labels << content_tag(:div, html.html_safe, :class => :item)
      end
    end

    wrapped ? content_tag(:div, labels.join("\n").html_safe, :class => "ui big horizontal list") : labels
  end

  def ui_image_src(url_1, url_2 = '/images/nobody-th.png')
    return url_1 unless url_1.blank?
    url_2
  end

  def ui_options_button_text
    content_tag(:i, '&nbsp;&nbsp;'.html_safe + t('page.title.actions'), :class => 'fa fa-cog')
  end

  def ui_nav_pills(items, options = {})
    content_tag :ul,  :class => "nav nav-pills #{options[:class]}" do
      html = ''
      items.each do |item|
        case item
        when String
          html << content_tag(:li, item)
        when Array
          html << content_tag(:li, item[0], :class => item[1] ? 'active' : nil )
        end
      end

      html.html_safe
    end
  end

  def ui_panel(header, action, body, table = nil, style = 'default')
    content_tag :div, class: "panel panel-#{style}" do
      html = ''

      if header.present? || action.present?
        html << content_tag(:div, "#{header} #{action}".html_safe, class: "panel-heading")
      end

      html << ( content_tag :div, class: "panel-body" do
        if body.present?
          case body
          when Array
            content_tag :ul do
              items = ''
              body.each_with_index do |link, ndx|
                if link.is_a?(Array)
                  items << content_tag(:li, "#{link[0]} #{link[1]}".html_safe)
                else
                  items << content_tag(:li, link)
                end
              end

              items.html_safe
            end
          else
            body
          end
        else
          t('page.text.no_record_found')
        end
      end ) if body.present?

      html << table if table.present?

      html.html_safe
    end
  end

  def ui_header(text, options = {})
    options[:style] ||= :h1

    #content_tag :div, class: "ui header" do
      html = ''
      html << options[:action] if options[:action].present?
      html << ( content_tag options[:style] do
        hdr = text
        if hdr
          if options[:subtext].present?
            hdr << tag(:br)
            hdr << content_tag(:small, options[:subtext])
          end

          hdr.html_safe
        end
      end )

      html.html_safe
    #end
  end

  def staff_or_student_view(default_action = nil)
    if @course && !@course.id.nil? && staff?(current_user, @course)
      klass = (@klass || @course.klasses.last)
      if klass && !klass.new_record?
        link :klass, :show, learn_klass_path(klass), as: :student_view, :class => 'btn btn-default pull-right'
      end
    elsif @klass && staff?(current_user, @klass.course)
      link :klass, :show, teach_course_klass_path(@klass.course, @klass), as: :instructor_view, :class => 'btn btn-default pull-right'
    else
      action = ''
      action << default_action if default_action.present?
      action
    end
  end

  def ui_alert (header, body, style = :success, dismissable = true)
    content_tag :div, class: "alert alert-#{style} #{'alert-dismissable' if dismissable}" do
      html = ''
      if dismissable
        html << content_tag(:button, '&times;'.html_safe, type: "button", class: "close", :'data-dismiss' => "alert")
      end

      html << content_tag(:strong, header) if header
      html << body

      html.html_safe
    end
  end

  def ui_media(media, heading, body, options = {kind: :div, align: :left})
    options[:kind] ||= :div
    options[:align] ||= :left
    options[:img_options] ||= {}

    content_tag options[:kind], class: "media", :id => options[:id] do
      html = ''
      html << ( content_tag :a , class: "pull-#{options[:align]}", href: "#" do
        if options[:video]
          ui_video(media, nil, thumbnail: true, :class => 'media-object img-polaroid pull-left')
        else
          image_tag media, {class: "media-object", alt: "#{options[:alt]}"}.merge(options[:img_options])
          #tag :img, { class: "media-object", src: "#{media}", alt: "#{options[:alt]}" }.merge(options[:img_options])
        end
      end )

      html << ( content_tag :div, class: "media-body" do
        main = (content_tag :div, class: "media-heading" do
          (options[:subhdr].present? ? (heading + content_tag(:small, options[:subhdr])) : heading).html_safe
        end )
        main << body

        main.html_safe
      end )

      html.html_safe
    end
  end

  def ui_label(text)
    content_tag :div, text, class: 'ui label'
  end

  def ui_item(media, hdr, labels, body, extra = nil, ribbon = nil)
    %(<div class="item">
        <div class="image">
          #{image_tag media}
          #{ribbon}
        </div>
        <div class="content">
          <div class="header">#{hdr}</div>
          <div class="meta">
            <div class="ui big horizontal list">
              #{labels.join("\n").html_safe}
            </div>
          </div>
          <div class="description">
            #{body}
          </div>
          <div class="extra">
            #{extra}
          </div>
        </div>
      </div>).html_safe
  end

  def ui_comment(media, author, date, body, actions, form, comments)
    %(<div class="comment">
        <div class="avatar">
          #{image_tag media}
        </div>
        <div class="content">
          <a class="author">#{author}</a>
          <div class="metadata">
            <span class="date">#{date}</span>
          </div>
          <div class="text">
            #{body}
          </div>
          <div class="actions">
            #{actions}
          </div>
        </div>
        #{form}
        <div class="comments">
          #{comments}
        </div>
      </div>).html_safe
  end

  def ui_modal(body, options = {})
    html = ''
    html << ( content_tag :div, class: "modal-header" do
      content_tag(:button, '&times;'.html_safe, type: "button", class: "close", :'data-dismiss' => "modal") +
      content_tag(:h4, options[:header], id: "page-modal-label", class: "modal-title")
    end ) if options[:header].present?

    html << content_tag(:div , body, class: "modal-body")

    html << ( content_tag :div, class: "modal-footer" do
      content_tag(:button, t('helpers.submit.close'), type: "button", class: "btn btn-default", :'data-dismiss' => "modal") +
      content_tag(:button, options[:action], type: "button", class: "btn btn-primary")
    end ) if options[:action].present?

    options[:wrapper] ||= false
    unless options[:wrapper]
      html.html_safe
    else
      content_tag :div, id: options[:wrapper], class: "modal fade" do
        content_tag :div, class: "modal-dialog" do
          content_tag :div, class: "modal-content" do
            html.html_safe
          end
        end
      end
    end
  end

	def ui_dropdown(name, links, options = {})
    wrapper = options[:wrapper] || :li
    options = options.reject { |k,v| k == :wrapper }
    options[:class] = "dropdown #{options[:class]}"
    content_tag wrapper, options  do
      html = ''
      html << ( content_tag :a , href: "#", class: "dropdown-toggle", :'data-toggle' => "dropdown" do
        (name + ' ' + content_tag(:b, '', :class => 'caret')).html_safe
      end )

      html << ( content_tag :ul, class: "dropdown-menu" do
        list = ''
    		links.each do |link|
    			if link.nil?
    				list << content_tag(:li, '', class: "divider")
          else
            list << content_tag(:li, link)
          end
    		end

        list.html_safe
      end )

      html.html_safe
    end
	end

  def ui_button_dropdown(name, links, options = {})
    content_tag :div, :class => "btn-group #{options[:dropdown_class]} #{css_align(options[:align]) if options[:align]}" do
      html = ''
      html << ( content_tag :button , type: "button", class: "dropdown-toggle #{options[:class]}", :'data-toggle' => "dropdown" do
        (name + ' ' + content_tag(:b, '', :class => 'caret')).html_safe
      end )

      html << ( content_tag :ul, class: "dropdown-menu" do
        list = ''
    		links.each do |link|
    			if link.nil?
    				list << content_tag(:li, '', class: "divider")
          else
            list << content_tag(:li, link)
          end
    		end

        list.html_safe
      end )

      html.html_safe
    end
  end
end