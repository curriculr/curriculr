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

  def form_checkbox_collection(form, field, collection, value, text, options = {}, html_options = {})
    label, hint = cleaned_options!(options)
    input = ( form.collection_check_boxes field, collection, value, text, options, html_options do |b|
      content_tag :div, :class => :checkbox do
        b.label { b.check_box(checked: b.value.in?(form.object.tags)) + b.text }
      end
    end )
    form_input_wrapper(form, field, input, label, hint)
  end

  def form_submit(form, cancel = nil, links = [], options = {})
    content_tag :div, class: "form-group" do
      key = options[:as] || case action_name
      when 'new', 'create'
        case controller_name
        when 'sessions'
          'sign_in'
        when 'registrations'
          'sign_up'
        when 'attempts'
          'submit'
        else
          "create"
        end
      when 'edit', 'update'
        "update"
      else
        "submit"
      end

      confirm = nil
      if options.present? && options[:data].present?
        confirm = options[:data][:confirm]
        title = options[:data][:"confirm-title"]
      end

      html = ''
      name = (options[:name] || t("activerecord.models.#{options[:model] || controller_name.classify.downcase}.one"))
      if confirm.present?
        html << %(
        <div id="form-modal" class="modal fade" role="dialog">
          <div class="modal-dialog modal-md">
            <div class="modal-content"></div>
          </div>
        </div>
        )
        link = content_tag(:button, name, type: "submit", class: options[:class])
        html << link_to(name, '#', :class => options[:class],
                  :onclick => "ui_modal_confirmation('form', '#{options[:data][:"confirm-title"] || t('page.title.hold_on')}', '#{confirm}', '#{j link}', '#{t('helpers.submit.close')}' )")
      else
        if options[:image]
          html << ( content_tag :button, type: "submit", style: "border: none; background: none;", data: {:'disable-with' => "#{css_animated_icon(:spinner)}"} do
            options[:image]
          end )
        else
          html << content_tag(:button, t(key, scope: "helpers.submit", name: name).html_safe,
              type: "submit", class: "btn btn-primary", data: {:'disable-with' => "#{css_animated_icon(:spinner)}"})
        end
      end

      html << " "
      if cancel.present?
        remote = options[:remote] || false
        if cancel == true
          html << link_to(t("helpers.submit.cancel"), _back_url, class: "btn btn-default", remote: remote)
        else
          html << link_to(t("helpers.submit.cancel"), cancel, class: "btn btn-default", remote: remote)
        end
      end

      links.each do |link|
        html << " "
        if link[:path].present?
          html << (link_to link[:text], link[:path])
        else
          html << link[:text]
        end
      end if links.present?

      html.html_safe
    end
  end
  
  def form_help
    render :partial => "/ui_form_help"
  end

  # def form_text(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.text_field(field, augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_text_area(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.text_area(field, augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end

  # def form_static(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   value = options[:value] || form.object[field]
  #   input = content_tag(:p, value, class: "form-control-static")
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_code(form, field, options = {})
  #   value = options[:value]
  #   lang = options[:lang]
  #   updated_field = options[:field]
  #   label, hint = cleaned_options!(options)
  #
  #   input = highlighted_code value, lang, updated_field
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_markdown(form, model, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = markdown_textarea(form, model, field, augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_password(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.password_field(field, augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_hidden(form, field, options = {})
  #   form.hidden_field(field,  augmented_options(form, field, options))
  # end
  #
  # def form_email(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.email_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_number(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.number_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_url(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.url_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_range(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.range_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  # 
  # def form_telephone(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.telephone_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_phone(form, field, options = {})
  #   form_telephone(form, field, options)
  # end
  #
  # def form_date(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.date_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_time(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.time_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_datetime(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.datetime_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_datetime_local(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.datetime_local_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_month(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.month_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_week(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.week_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_color(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.color_field(field,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_file(form, field, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.file_field(field, options)
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_checkbox(form, field, options = {}, checked_value = "1", unchecked_value = "0")
  #   label, hint = cleaned_options!(options)
  #   text = case label
  #   when TrueClass
  #     t("activerecord.attributes.#{form.object.class.name.underscore}.#{field}")
  #   when FalseClass
  #     ''
  #   else
  #     label
  #   end
  #   input = form.label field do
  #     form.check_box(field, options) + " #{text}"
  #   end
  #
  #   form_input_wrapper(form, field, input, false, hint)
  # end
  #
  # def form_radio_button(form, field, tag, options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.radio_button(field, tag,  augmented_options(form, field, options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_select(form, field, collection, options = {include_blank: true}, html_options = {})
  #   label, hint = cleaned_options!(options)
  #   value = options[:value].present? ? options[:value] : (
  #     form.object.respond_to?(:[]) ? form.object[field] : nil)
  #
  #   case collection
  #   when Hash
  #     select_options = options_for_select(collection, value)
  #   else
  #     if collection.kind_of?(Array) && (
  #         collection.first.kind_of?(Symbol) ||
  #         collection.first.kind_of?(String) ||
  #         collection.first.kind_of?(Fixnum)
  #        )
  #
  #       select_options = options_for_select(collection, value)
  #     else
  #       value_method = :id
  #       text_method = :name
  #
  #       select_options = options_from_collection_for_select(collection, value_method, text_method, value)
  #     end
  #   end
  #
  #   options = options.delete_if {|k,v| %w(value).include? 'k' }
  #   input = form.select(field, select_options, options, augmented_options(form, field, html_options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_time_zone(form, field, options = {}, html_options = {})
  #   label, hint = cleaned_options!(options)
  #   input = form.time_zone_select(field, ActiveSupport::TimeZone.all.sort,
  #     options, augmented_options(form, field, html_options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
  #
  # def form_country_select(form, field, options = {iso_codes: true}, html_options = {})
  #   label, hint = cleaned_options!(options)
  #   options[:iso_codes] = true
  #   input = form.country_select(field, nil, options, augmented_options(form, field, html_options))
  #   form_input_wrapper(form, field, input, label, hint)
  # end
end
