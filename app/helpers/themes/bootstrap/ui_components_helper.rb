# For ui components: css, html, and js
module Themes::Bootstrap::UiComponentsHelper
  def ui_klass_labels(klass)
    labels = ui_course_labels(klass.course)
    if klass.private
      labels << content_tag(:div, Klass.human_attribute_name(:private), :class => 'ui label')
    end

    labels << mountable_fragments(:klass_attributes_actions, :klass => klass, :lables => labels)
    labels.html_safe
  end

  def ui_course_labels(course)
    labels = ''
    unless course.country.blank?
      labels << content_tag(:div, flag_tag(course.country), :class => 'ui label')
    end

    Translator.to_hash(I18n.locale, "#{current_account.slug}.site.level.*").each_with_index do |l, i|
      if Course.scoped.tagged_with(l.first, :on => :levels).to_a.include? course
        labels << content_tag(:div, l.second, :class => 'ui label')
      end
    end

    labels.html_safe
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
    left = content_tag options[:style], class: 'ui orange left floated header' do
      hdr = text
      hdr << content_tag(:div, options[:subtext], class: 'sub header') if options[:subtext].present?
      
      hdr.html_safe
    end
    right = content_tag(:div, options[:action].html_safe, class: 'ui right floated header') if options[:action].present?
    content_tag(:div, left + right, class: 'page clearing header')
    #content_tag :div, left + right, class: "ui basic clearing segment"
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
    content_tag :div, class: options[:class] do
      html = content_tag :span, text, class: 'text'
      html << ui_icon('dropdown')
      html << content_tag(:div, links.join("\n").html_safe, class: 'menu')
      
      html.html_safe
    end
  end
end