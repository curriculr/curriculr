class Mailer < Devise::Mailer
  include Roadie::Rails::Automatic
  #include Devise::Controllers::UrlHelpers 
  helper :application
  layout 'mailer'
  
  def prepare_msg(account)
    @site_url = root_url
    @site_logo = t("#{account}.site.mailer.logo")
    @site_link = view_context.link_to(@site_url) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.view_site"), class: "template-label"
    end
    
    @footer = t("#{account}.site.mailer.footer_html", :site_url => @site_url)
  end

  # Contact us emails
  def contactus_email(from, to, msg)
    prepare_msg(msg[:account])

    @url = view_context.mail_to(msg[:contact_email]) do
      view_context.content_tag :span, msg[:contact_email]
    end
    @subject = msg[:subject]
    @body = %(<p>From: #{msg[:name]}</p><p>#{msg[:message]}</p>).html_safe
    
    mail(:from => from, :to => to, :subject => msg[:subject], template_name: 'basic')
  end

  def confirmation_instructions(uid, account, token, opts={})
    prepare_msg(account)
    record = User.find(uid)
    @url = view_context.link_to(url_for(controller: 'devise/confirmations', action: 'show', confirmation_token: token)) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.confirm_account")
    end
      
    @subject = t("#{account}.site.mailer.confirmation_instructions.subject")
    @body = t("#{account}.site.mailer.confirmation_instructions.body_html", :name => record.email, :url => @url)
    mail(:from => opts[:from], :to => opts[:to], :subject => @subject, template_name: 'basic')
  end

  def reset_password_instructions(uid, account, token, opts={})
    prepare_msg(account)
    record = User.find(uid)
    @url = view_context.link_to(url_for(controller: 'devise/passwords', action: 'edit', reset_password_token: token)) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.change_password")
    end
      
    @subject = t("#{account}.site.mailer.reset_password_instructions.subject")    
    @body = t("#{account}.site.mailer.reset_password_instructions.body_html", :name => record.email, :url => @url)
    mail(:from => opts[:from], :to => opts[:to], :subject => @subject, template_name: 'basic')
  end

  def unlock_instructions(uid, account, token, opts={})
    record = User.find(uid)
    super(record, token, opts)
  end
  
  # Klass invitation emails
  def klass_invitation(account, from, to, kid, name, url)
    prepare_msg(account)
    @url = view_context.link_to(url) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.sign_in")
    end

    klass = Klass.find(kid)
    @klasses = [ klass ]
    @subject = "#{t("#{account}.site.title")}: #{t("#{account}.site.mailer.klass_invitation.subject")}"
    @body = t("#{account}.site.mailer.klass_invitation.body_html", :name => name, :url => @url, 
      :course_name => klass.course.name)
      
    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end
  
  # Klass enrollment emails
  def klass_enrollment(account, from, to, klasses, url)
    prepare_msg(account)
    @url = view_context.link_to(url) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.sign_in")
    end

    @klasses = Klass.find(klasses)
    @subject = "#{t("#{account}.site.title")}: #{t("#{account}.site.mailer.klass_enrollment.subject")}"
    @body = t("#{account}.site.mailer.klass_enrollment.body_html", :url => @url)
      
    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic') 
  end
  
  # Update emails
  def klass_update(account, from, to, subject, body, kid)
    prepare_msg(account)
    @url = view_context.link_to(learn_klass_url(kid)) do
      view_context.content_tag :span, t("#{account}.site.mailer.links.go_to_class")
    end
    @subject = "#{t("#{account}.site.title")}: #{subject}"
    @body = body
      
    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end
end
