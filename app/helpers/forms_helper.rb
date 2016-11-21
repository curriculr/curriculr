module FormsHelper
  def form_header(options = {})
    key = case action_name
    when 'new', 'create'
      "new"
    when 'edit', 'update'
      "edit"
    else
      action_name
    end

    t(key, scope: 'helpers.submit', name: t("activerecord.models.#{controller_name.classify.downcase}.one"))
  end

  def set_form_class(options)
    if options[:html]
      if options[:html][:class]
        options[:html][:class] = "ui form #{options[:html][:class]}"
      else
        options[:html][:class] = 'ui form'
      end
    else
      options[:html] = {class: 'ui form'}
    end
  end
  
  def modal_form_for(record, options = {}, &block) 
    set_form_class(options)
    options[:builder] = ModalFormBuilder
    options[:remote] = true
    
    form = form_for(record, options, &block)
    
    html = ui_icon(:close)
    html << content_tag(:div, options[:header] || form_header, class: 'header')
    html << content_tag(:div, form, class: 'content')
    html << content_tag(:div, content_tag(:button, 'Cancel', class: 'ui negative cancel button') +
      content_tag(:button, 'Submit', class: 'ui primary submit-form ok button'), class: 'actions')
      
    content_tag :div, html.html_safe, class: 'ui modal', id: "the-modal-form"
  end
  
  def form_for(record, options = {}, &block)
    set_form_class(options)
    super
  end
  
  def form_files(form, field, options = {})
    hint = options.include?(:hint) ? options[:hint] : false
    label = options.include?(:label) ? (options[:label] == false ? false : options[:label]) : true
    options.reject!{|k,v| %(hint label).include? k.to_s}
    input = form.file_field(field, options.merge({label: false, multiple: true, style: 'display: none;'}))
    content_tag :div, class: "field drag-file-area" do
      %(
        <div class="ui primary button">
            #{form.label(field, ui_icon(:plus) + label)}
            #{input}
        </div>
        #{content_tag :span, hint if hint}
      ).html_safe
    end
  end
end