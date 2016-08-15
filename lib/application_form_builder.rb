class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  [ :text_field, :password_field, :text_area, :file_field, :color_field, 
    :search_field, :phone_field, :telephone_field, :date_field, 
    :time_field, :datetime_field, :month_field, :week_field, :url_field, 
    :email_field, :number_field, :range_field ].each do |method|
    define_method method do |attribute, options={}|
      if options[:placeholder].is_a?(TrueClass)
        options[:placeholder] = I18n.t(:"helpers.placeholder.#{attribute}")
      end
      
      wrap_field(super(attribute, cleaned_options(options)), attribute, options)
    end
  end
  
  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    field = label attribute do
      super(attribute, options, checked_value, unchecked_value) + ' ' + @object.class.human_attribute_name(attribute)
    end
    wrap_field(field, attribute, options.merge({label:  false}))
  end
  
  def radio_button(attribute, tag_value, options = {}) 
    wrap_field(super(attribute, tag_value, options), attribute, options)
  end
    
  def select(attribute, choices = nil, options = {}, html_options = {})
     wrap_field(super(attribute, choices, options, html_options), attribute, html_options)
  end
  
  def static(attribute, options = {})
    wrap_field(@template.content_tag(:p, options[:value] || @object[attribute], class: "static"), attribute, options)
  end
  
  def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
    wrap_field(super(attribute, priority_zones, options, html_options), attribute, html_options)
  end
  
  def markdown(attribute, options = {})    
    wmd_id = options[:data] || attribute.to_s
    options[:data] ||= wmd_id 
    options[:size] ||= '60x10'
    
    output = %(<div class="input"><div class="wmd-panel"><div id="wmd-button-bar#{wmd_id}"></div>)
    output += text_area attribute, options.merge({original: true, id: "wmd-input#{wmd_id}", class: 'wmd-input'})
    output += "</div>"
    output += %(<div id="wmd-preview#{wmd_id}" class="wmd-panel wmd-preview well"></div>) if options[:preview]
    output += "</div>"
    
    wrap_field(output.html_safe, attribute, options)
  end
  
  def code(attribute, options = {})
    value = options[:value]
    lang = options[:lang]
    updated_field = options[:field]
    #label, hint = cleaned_options!(options)

    field = @template.highlighted_code value, lang, updated_field
    #form_input_wrapper(form, field, input, label, hint)
    wrap_field(field, attribute, options)
  end
  
  def country_select(attribute, priority_or_options = {}, options = {iso_codes: true}, html_options = {})
    options[:iso_codes] = true
    wrap_field(super(attribute, nil, options, html_options), attribute, options)
  end
  
  private
    def cleaned_options(options)
      options.reject{|k,v| [:hint, :label, :original].include? k}
    end
    
    def wrap_field(field, attribute, options={})
      if options[:original]
        field
      else
        has_error = !!(@object && @object.errors && @object.errors.include?(attribute))

        validators = @object.class.respond_to?(:validators_on) ? @object.class.validators_on(attribute).map(&:class) : nil
        required = !!(validators && (validators.include?(ActiveRecord::Validations::PresenceValidator) || validators.include?(ActiveModel::Validations::PresenceValidator)))
  
        @template.content_tag :div, class: "#{required ? 'required ' : ''}field#{has_error ? ' with-errors' : ''}" do
          html = ''
          
          case options[:label]
          when String
            html << options[:label].html_safe
          when FalseClass
            html << ''
          else
            html << label(attribute)
          end 
  
          html << field
          html << @template.content_tag(:span, @object.errors[attribute].join('; '), class: 'error') if has_error
          html << @template.content_tag(:span, I18n.t(:"helpers.hint.#{attribute}").html_safe, class: :hint) if options[:hint].is_a?(TrueClass)
    
          html.html_safe
        end
      end
    end
end
