# For form components
module Themes::Bootstrap::FormsHelper
  def themed_form_for(record, options = {}, &block)
    form_for(record, options, &block)
  end

  def form_header(options = {})
    header = options[:text]
    unless header
      key = case action_name
      when 'new', 'create'
        "new"
      when 'edit', 'update'
        "edit"
      else
        action_name
      end

      name = (options[:name] || t("activerecord.models.#{options[:model] || controller_name.classify.downcase}.one"))
      header = t(key, scope: 'helpers.submit', name: name )
    end
    
    options[:wrapper] = true if options[:wrapper].nil?
    style = (options[:style] || :h3)
    unless options[:wrapper]
      content_tag style, header.html_safe
    else
      content_tag :div, class: "page-header" do
        content_tag style, header.html_safe
      end
    end
  end

  def form_input_wrapper(form, field, input, label = true, hint = false)
    has_error = form.object.respond_to?(:errors) && form.object.errors[field].present?
    content_tag :div, class: "form-group #{"has-error" if has_error}" do
      validators = form.object.class.respond_to?(:validators_on) ? form.object.class.validators_on(field).map(&:class) : nil
      if validators && (validators.include?(ActiveRecord::Validations::PresenceValidator) ||
         validators.include?(ActiveModel::Validations::PresenceValidator))
        style_class = "control-label required"
      else
        style_class = "control-label"
      end

      html = case label
      when TrueClass
        form.label(field, class: style_class)
      when FalseClass
        ''
      else
        form.label(field, label, class: style_class)
      end

      html << ' '
      html << input
      if has_error
        html << ( content_tag :span, form.object.errors[field].join(' '), class: "help-block" )
      elsif hint
        case hint
        when TrueClass
          hint = t(:"helpers.hint.#{field}").html_safe
        end

        html << ( content_tag :span, hint, class: "help-block") if hint
      end

      html.html_safe
    end
  end

  def augmented_options(form, field, options)
    to = { class: "form-control" }
    to.each do |k, v|
      options[k] = options[k].present? ? "#{options[k]} #{v}" : v
    end

    placeholder = true?(options[:placeholder])
    if placeholder
      options[:placeholder] = t(:"helpers.placeholder.#{field}")
    end

    options
  end

  def cleaned_options!(options)
    hint = options.include?(:hint) ? options[:hint] : false
    #hint = options.include?(:hint) && options[:hint] == true ? true : false
    #label = options.include?(:label) && options[:label] == false ? false : true
    label = options.include?(:label) ? (options[:label] == false ? false : options[:label]) : true
    options.reject!{|k,v| %(hint label).include? k.to_s}

    return label, hint
  end

  def form_search(form, field, options = {})
    label, hint = cleaned_options!(options)
    input = form.search_field(field,  augmented_options(form, field, options))
    form_input_wrapper(form, field, input, label, hint)
  end

  def form_files(form, field, options = {})
    label, hint = cleaned_options!(options)
    input = form.file_field(field, options.merge({:multiple => true}))
    content_tag :div, class: "form-group drag-file-area" do
      %(
        <span class="btn btn-success btn-file">
            #{css_icon(:plus, 2)}
            <span>#{label}</span>
            #{input}
        </span>
        #{content_tag :span, hint if hint}
      ).html_safe
    end
  end
end
