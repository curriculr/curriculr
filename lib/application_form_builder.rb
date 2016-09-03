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
  
  def static(attribute, options = {})
    wrap_field(@template.content_tag(:p, options[:value] || @object[attribute], class: "static"), attribute, options)
  end
  
  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    field = @template.content_tag :div, class: 'ui checkbox' do
      super(attribute, cleaned_options(options), checked_value, unchecked_value) + label(attribute) 
    end
    
    wrap_field(field, attribute, options.merge({label:  false}))
  end
  
  def collection_check_boxes(attribute, collection, value, text, options = {}, html_options = {})
    options[:label] = @template.content_tag :label, options[:label] if options[:label]
    
    field = ( super attribute, collection, value, text, cleaned_options(options), html_options do |b|
      b.label { b.check_box(checked: b.value.in?(@object.tags)) + ' ' + b.text}
    end )
    
    wrap_field(field, attribute, options)
  end
  
  def radio_button(attribute, tag_value, options = {}) 
    wrap_field(super(attribute, tag_value, options), attribute, options)
  end
    
  def select(attribute, choices = nil, options = {}, html_options = {})
    html_options[:class] = 'ui dropdown'
    wrap_field(super(attribute, choices, options, html_options), attribute, html_options)
  end
  
  def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {class: 'ui dropdown'})
    wrap_field(super(attribute, priority_zones, options, html_options), attribute, html_options)
  end
  
  def country_select(attribute, priority_or_options = {}, options = {iso_codes: true}, html_options = {class: 'ui dropdown'})
    options[:iso_codes] = true
    wrap_field(super(attribute, nil, options, html_options), attribute, options)
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
  
  def submit(value = nil, options = {})
    css_class = 'ui primary button'
    value = case value
    when Symbol
      I18n.t("helpers.submit.#{value}").html_safe
    when String
      value
    else
      nil
    end
    
    html = ''
    if options[:data] && options[:data][:confirm].is_a?(TrueClass)
      link = button(value, class: css_class)
      html << @template.content_for(:div, value, class: %(ui confirm-first primary button), data: {header: data[:header], content: data[:content], action: link, cancel: I18n.t('helpers.submit.close')})
    else
      html << button(value, class: css_class)
    end
    
    html.html_safe
  end
  
  def cancel(url = nil)
    @template.link_to(I18n.t("helpers.submit.cancel"), url || @template._back_url, class: "button")
  end
  
  private
    def cleaned_options(options)
      options.reject{|k,v| [:hint, :label, :original].include? k}
    end
    
    def required?(attribute)
      !!(object&.class&.validators_on(attribute)&.any? {|v| v.kind_of? ActiveModel::Validations::PresenceValidator})
    end
    
    def has_errors?(attribute)
      object&.errors&.include?(attribute)
    end
    
    def wrap_field(field, attribute, options={})
      if options[:original]
        field
      else
        classes = []
        # classes << options[:class] if options[:class]
        classes << 'required' if required?(attribute)
        classes << 'error' if has_errors?(attribute)
        classes << 'field'

        @template.content_tag :div, class: classes.join(' ') do
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
          html << @template.content_tag(:span, @object.errors[attribute].join('; '), class: 'error') if has_errors?(attribute)
          html << @template.content_tag(:span, I18n.t(:"helpers.hint.#{attribute}").html_safe, class: :hint) if options[:hint].is_a?(TrueClass)
    
          html.html_safe
        end
      end
    end
end
