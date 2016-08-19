# Bootstrap implementation of theme related ui elements
module Themes::Bootstrap::CssHelper
  def css_container(style = nil)
    if style
       "container-#{style}"
    elsif @current_theme && @current_theme['fluid']
      "container-fluid"
    else
      "container"
    end
  end

  def css_columns(columns = 16, offset = 0)
    if offset > 0
      "col-md-#{columns} col-md-offset-#{offset}"
    else
      "col-md-#{columns}"
    end
  end

  def css_align(direction)
    "pull-#{direction}"
  end

  def css_text(type)
    "text-#{type}"
  end

  # def css_table(styles=[:hover])
  #   "table #{styles.map {|s| "table-#{s}"}.join(' ')}"
  # end

  def css_button(*styles)
    'group'.in?(styles) ? 'btn-group' : "btn #{styles.map {|s| "btn-#{s}"}.join(' ')}"
  end

  def css_alert(style)
    "alert alert-#{style}"
  end

  def css_form(type)
    "form-#{type}"
  end

  def css_badge
    "badge"
  end

  def css_label(style)
    "label label-#{style}"
  end

  def css_nav(style)
    "nav nav-#{style}"
  end

  def css_breadcrumb
    "breadcrumb"
  end

  def css_image(*styles)
    "img #{styles.map {|s| "img-#{s}"}.join(' ')}"
  end

  def css_icon(name, spaces = 0)
    cls = name.kind_of?(Array) ? name.map{|n| "fa-#{n}"}.join(' ') : "fa-#{name}"
    content_tag :i, ('&nbsp;' * spaces).html_safe, class: "fa #{cls}"
  end

  def css_animated_icon(name, spin = true)
    content_tag :i, '', class: "fa fa-#{name} fa-#{spin ? "spin" : "pulse"}"
  end

  def css(options = {})
    output = []
    options.each do |k, v|
      case k
      when :button
        output << css_button(*v)
      when :align
        output << css_align(v)
      end
    end

    output.join(' ')
  end

  def css_form_control
    "form-control"
  end
end
