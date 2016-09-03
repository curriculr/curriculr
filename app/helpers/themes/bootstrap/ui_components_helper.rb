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

  def ui_options_button_text
    content_tag(:i, '&nbsp;&nbsp;'.html_safe + t('page.title.actions'), :class => 'fa fa-cog')
  end

  # def ui_panel(header, action, body, table = nil, style = 'default')
  #   content_tag :div, class: "panel panel-#{style}" do
  #     html = ''
  #
  #     if header.present? || action.present?
  #       html << content_tag(:div, "#{header} #{action}".html_safe, class: "panel-heading")
  #     end
  #
  #     html << ( content_tag :div, class: "panel-body" do
  #       if body.present?
  #         case body
  #         when Array
  #           content_tag :ul do
  #             items = ''
  #             body.each_with_index do |link, ndx|
  #               if link.is_a?(Array)
  #                 items << content_tag(:li, "#{link[0]} #{link[1]}".html_safe)
  #               else
  #                 items << content_tag(:li, link)
  #               end
  #             end
  #
  #             items.html_safe
  #           end
  #         else
  #           body
  #         end
  #       else
  #         t('page.text.no_record_found')
  #       end
  #     end ) if body.present?
  #
  #     html << table if table.present?
  #
  #     html.html_safe
  #   end
  # end

  def ui_header(text, options = {})
    options[:style] ||= :h1
    right = ''
    left = content_tag options[:style], class: 'ui left floated header' do
      hdr = text
      hdr << content_tag(:div, options[:subtext], class: 'sub header') if options[:subtext].present?
      
      hdr.html_safe
    end
    right = content_tag(:div, options[:action].html_safe, class: 'ui right floated header') if options[:action].present?
    content_tag(:div, left + right, class: 'page clearing header')
    #content_tag :div, left + right, class: "ui basic clearing segment"
  end
  
  def ui_side_by_side(side_a, side_b, config = 'twelve by four')
    sizes = config.split('by').map{|s| s.chomp }
    content_tag :div, class: "ui two column grid" do
      html = ''
      html << content_tag(:div, side_a, class: "ui left floated #{sizes[0]} wide column") unless sizes[0] == 'zero'
      html << content_tag(:div, side_b, class: "ui right floated #{sizes[1]} wide column") unless sizes[1] == 'zero'

      html.html_safe
    end
  end

  def staff_or_student_view(default_action = nil)
    if @course && !@course.id.nil? && staff?(current_user, @course)
      klass = (@klass || @course.klasses.last)
      if klass && !klass.new_record?
        link_to learn_klass_path(klass), class: 'ui positive basic button' do
          ui_icon(:student) + ' ' + t('helpers.submit.student_view')
        end
      end
    elsif @klass && staff?(current_user, @klass.course)
      link_to teach_course_klass_path(@klass.course, @klass), class: 'ui positive basic button' do
        ui_icon(:doctor) + ' ' + t('helpers.submit.instructor_view')
      end
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

  def ui_buttons(buttons)
    content_tag :div, class: "ui buttons" do
      html = ''
      buttons.each do |button|
        html << button unless button.nil?
      end
      html.html_safe
    end
  end
  
  def ui_dropdown_button(text, links, options = {class: 'ui dropdown primary button'})
    content_tag :div, class: options[:class] do
      html = content_tag :span, text, class: 'text'
      html << ui_icon('dropdown')
      html << content_tag(:div, links.join("\n").html_safe, class: 'menu')
      
      html.html_safe
    end
  end
  
  def ui_button_dropdown(name, links, options = {})    
    content_tag :div, class: "ui tiny #{options[:align] if options[:align]} buttons" do
      html = content_tag(:div, ui_icon(:settings) + name, class: "ui button")
      html << ( content_tag :div, class: "ui floating dropdown icon button" do
        list = ui_icon(:dropdown)
        list << ( content_tag :div, class: 'menu' do
          menu = ''
      		links.each do |link|
      			if link.nil?
      				menu << content_tag(:div, '', class: 'divider')
            else
              menu << content_tag(:div, link, class: 'item')
            end
      		end
          
          menu.html_safe
        end )

        list.html_safe
      end )

      html.html_safe
    end
  end
end