module ApplicationHelper  
  def title
    title = t("#{current_account.slug}.site.title", :default => current_account.config['title'] || $site['title'])
    title.html_safe if title.present?
  end

  def page_title
    if @klass
      %(#{title}: #{@klass.course.name})
    else
      title
    end
  end
  
  def rtl?
    # To be expanded later
    [:ar, :he].include? locale
  end

  def scoped_t(*args)
    key, params =  *args
    params = {} if params.blank?
    params[:default] = t(key.sub(/^[^\.]*\./, 'account.'), params)

    t(key, params)
  end
  
  def link_text(model, action, options = {})
    text = case action
    when :index
      t("activerecord.models.#{model}.other")
    when :new, :create, :edit, :update, :destroy
      t(action, scope: 'helpers.submit', :name => '')
    else
      key = (options.present? && options[:as].present?) ? "#{action}_#{options[:as]}" : action

      t(key, scope: 'helpers.submit')
    end
    
    text.html_safe
  end
  
  def link(model, action, path = nil, options = {})
    text = link_text(model, action, options)

    if options.present? && (confirm = options[:confirm]) && confirm.present? && confirm == true
      confirmation = options[:content] || t(action, scope: 'helpers.confirmation', :name => t("activerecord.models.#{model}.one"))

      default = options[:as].present? ? options[:as].to_sym : action.to_sym
      custom_options = options.reject{|k,v| %w(data confirm as header content).include? (k.to_s) }
      link = link_to(text, path, custom_options)


      return link_to(text, '#', class: "#{options[:class]} confirm-first", data: {
        header: options[:header] || t('page.title.hold_on'), content: confirmation, action: link, cancel: t('helpers.submit.close')})
    end
    
    link_to(text, path, options)
  end

  def klass_from_and_to_dates(klass)
    text = l(klass.begins_on)
    if klass.ends_on
      text << ' - '
      text << l(klass.ends_on)
    end

    text
  end

  def to_medium_kind(kind)
    return :video unless kind

    case kind.to_sym
    when :poster
      :image
    when :videos
      :video
    when :slides
      :document
    when :notes
      :document
    when :books
      :document
    when :data
      :other
    else
      kind.to_sym
    end
  end
end
