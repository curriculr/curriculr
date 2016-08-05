# For displaying JSON Settings in a tree-like form
module Themes::Bootstrap::SettingsTreeHelper
  def json_settings_form_value(object)
    case object
    when TrueClass, FalseClass
      html = hidden_field_tag(:type, 'boolean')
      html << (content_tag :div, class: "radio-inline" do
        label_tag :value_1 do
          radio_button_tag(:value, "1",  object == true) + " true"
        end
      end)

      html << (content_tag :div, class: "radio-inline" do
        label_tag :value_0 do
          radio_button_tag(:value, "0", object == false) + " false"
        end
      end)
    when Numeric
      html = hidden_field_tag(:type, 'numeric')
      html << (content_tag :div, class: "form-group" do
        label_tag(:value, "Value") + number_field_tag(:value, object, class: 'form-control')
      end)

    when Array
      html = hidden_field_tag(:type, 'array')
      html << (content_tag :div, class: "form-group" do
        label_tag(:value, "Value") + text_area_tag(:value, object.join(', '), class: 'form-control')
      end)
    else
      html = hidden_field_tag(:type, 'text')
      html << (content_tag :div, class: "form-group" do
        if object && object.size > 60
          label_tag(:value, "Value") + text_area_tag(:value, object, class: 'form-control', rows: 8)
        else
          label_tag(:value, "Value") + text_field_tag(:value, object, class: 'form-control')
        end
      end)
    end

    html.html_safe
  end

  def json_settings_tree(url, parent, object, s, path, depth, addable_to_levels = [])
    case object
    when TrueClass, FalseClass, Numeric, Array, String, NilClass
      s << "<code>#{object}</code>&nbsp;&nbsp;&nbsp;"
      s << link(:setting, :edit, '#', :class => 'btn btn-default btn-xs btn-edit-setting', :data => {
        form: render(:partial => '/application/settings/setting_form', :locals => {
          object: object, value: object, :key => path.last,
          :url => url.sub('_key_', path.take(depth-2).join(':')), :op => :edit,
          :title => "Edit a setting", :path => path.join('/')
        }).gsub("\n", "")
      })

      if addable_to_levels.include?(depth - 2)
        s << '&nbsp;'
        s << link(:setting, :destroy, url.sub('_key_', path.join(':')), method: :delete, confirm: true,
          class: 'btn btn-danger btn-xs btn-delete-setting')
      end
    when Hash
      s << '<ul dir="ltr">'

      object.each do |k, v|
        path << k
        s << "<li><strong>#{k.titleize}</strong>: "
        if addable_to_levels.include?(depth) && v.kind_of?(Hash)
          s << link(:setting, :new, '#', :class => 'btn btn-success btn-xs btn-add-setting', :data => {
            form: render(:partial => '/application/settings/setting_form', :locals => {
              object: v, :key => '', :value => '', :title => "Add a setting",
              type: v.first.kind_of?(Array) ? v.first.second : v,
              :url => url.sub('_key_', path.join(':')), :op => :add, :path => path.join('/')
            }).gsub("\n", "")
          })
        end

        json_settings_tree(url, object, v, s, path, depth + 1, addable_to_levels)
        s << '</li>'
        path.pop
      end

      s << '</ul>'
    end
  end
end
