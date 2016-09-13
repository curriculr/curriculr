class ModalFormBuilder < ApplicationFormBuilder  
  def submit(value = nil, options = {})
    # options[:class] ||= 'ui primary ok button'
    # html = super(value, options)
    # html << @template.content_tag(:div, I18n.t("helpers.submit.cancel"), class: 'ui negative cancel button')
    #
    # html.html_safe
    nil
  end
  def cancel(url = nil, options={})
    nil
  end
end
