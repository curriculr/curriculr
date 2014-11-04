class Mailer < Devise::Mailer
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers 
  before_action :set_current_account
  helper :application
  layout 'mailer'
  
  def set_current_account
    @account = Account.find(Account.current_id)
    @site_url = root_url
    @site_logo = t("#{@account.slug}.site.mailer.logo")
    @site_link = view_context.link_to(@site_url) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.view_site"), class: "template-label"
    end
    
    @footer = t("#{@account.slug}.site.mailer.footer_html", :site_url => @site_url)
  end
  
  def confirmation_instructions(record, token, opts={})
    @url = view_context.link_to(confirmation_url(record, :confirmation_token => token)) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.confirm_account")
    end
      
    @subject = t("#{@account.slug}.site.mailer.confirmation_instructions.subject")
    opts[:subject] = @subject
    opts[:template_name] = 'basic'
  
    @body = t("#{@account.slug}.site.mailer.confirmation_instructions.body_html", :name => record.email, :url => @url)
    super(record, token, opts)
  end

  def reset_password_instructions(record, token, opts={})
    @url = view_context.link_to(edit_password_url(record, :reset_password_token => token)) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.change_password")
    end
      
    @subject = t("#{@account.slug}.site.mailer.reset_password_instructions.subject")
    opts[:subject] = @subject
    opts[:template_name] = 'basic'
    
    @body = t("#{@account.slug}.site.mailer.reset_password_instructions.body_html", :name => record.email, :url => @url)
    super(record, token, opts)
  end

  def unlock_instructions(record, token, opts={})
    @url = view_context.link_to(unlock_url(@resource, :unlock_token => @resource.unlock_token)) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.unlock_account")
    end
      
    @subject = t("#{@account.slug}.site.mailer.unlock_instructions.subject")
    opts[:subject] = @subject
    opts[:template_name] = 'basic'
  
    @body = t("#{@account.slug}.site.mailer.unlock_instructions.body_html", :name => record.email, :url => @url)
    super(record, token, opts)
  end
  
  # Contact us emails
  def contactus_email(current_account, message)
    @account = current_account
    @from = current_account.config['mailer']['from']
    @to = message.to
    @name = message.name
    @subject = message.subject
    @url = view_context.mail_to(message.email) do
      view_context.content_tag :span, message.email
    end
    
    @body = %(<p>From: #{message.name}</p><p>#{message.content}</p>).html_safe
    
    mail(:from => @from, :to => @to, :subject => @subject, template_name: 'basic')
  end
  
  # Klass invitation emails
  def klass_invitation(current_account, name, klass, email, url)
    @account = current_account
    @from = current_account.config['mailer']['from']
    @to = email
    @name = name
    @url = view_context.link_to(url) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.sign_in")
    end
    @klass = klass
    @subject = "#{t("#{current_account.slug}.site.title")}: #{t("#{current_account.slug}.site.mailer.klass_invitation.subject")}"
    @body = t("#{current_account.slug}.site.mailer.klass_invitation.body_html", :name => @name, :url => @url, 
      :course_name => @klass.course.name)
      
    mail(:from => @from, :to => @to, :subject => @subject, template_name: 'basic')
  end
  
  # Klass enrollment emails
  def klass_enrollment(current_account, email, klasses, url, payment = nil)
    @account = current_account
    @from = current_account.config['mailer']['from']
    @to = email
    @url = view_context.link_to(url) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.sign_in")
    end
    @klasses = klasses
    @subject = "#{t("#{current_account.slug}.site.title")}: #{t("#{current_account.slug}.site.mailer.klass_enrollment.subject")}"
    @body = t("#{current_account.slug}.site.mailer.klass_enrollment.body_html", :url => @url)
      
    mail(:from => @from, :to => @to, :subject => @subject, template_name: 'basic') 
  end
  
  # Update emails
  def klass_update(current_account, from, email, subject, body, klass)
    @account = current_account
    @from = from
    @to = email
    @url = view_context.link_to(learn_klass_url(klass)) do
      view_context.content_tag :span, t("#{@account.slug}.site.mailer.links.go_to_class")
    end
    @subject = "#{t("#{current_account.slug}.site.title")}: #{subject}"
    @body = body
      
    mail(:from => @from, :to => @to, :subject => @subject, template_name: 'basic')
  end
end
