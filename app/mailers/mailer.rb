class Mailer < Devise::Mailer
  include ApplicationHelper
  layout 'mailer'

  def prepare_msg(account, title=nil)
    @site_url = root_url
    @site_logo = t("#{account}.site.mailer.logo")
    title = scoped_t("#{account}.site.title") unless title
    @site_link = view_context.link_to(title || :curriculr, @site_url)
    @preheader = t("page.text.the_last_information_from_html", url: @site_link)

    @footer = scoped_t("#{account}.site.mailer.footer_html", :site_url => @site_url).html_safe
  end

  def prepare_url(text, link, mail_to = false)
    @url_text, @url_link = text, link
    @mail_to_url = mail_to
    if mail_to
      view_context.mail_to(text, link)
    else
      view_context.link_to(text, link)
    end
  end
  # Contact us emails
  def contactus_email(from, to, msg)
    prepare_msg(msg[:account])

    @url = prepare_url(msg[:contact_email], msg[:contact_email], true)

    @subject = msg[:subject]
    @body = %(<p>From: #{msg[:name]}</p><p>#{msg[:message]}</p>).html_safe

    mail(:from => from, :to => to, :subject => msg[:subject], template_name: 'basic')
  end

  def confirmation_instructions(uid, account, token, opts={})
    prepare_msg(account)
    record = User.find(uid)

    @url = prepare_url(scoped_t("#{account}.site.mailer.links.confirm_account"), url_for(controller: 'devise/confirmations', action: 'show', confirmation_token: token))

    @subject = scoped_t("#{account}.site.mailer.confirmation_instructions.subject")
    @body = scoped_t("#{account}.site.mailer.confirmation_instructions.body_html", :name => record.email, :url => @url)
    mail(:from => opts[:from], :to => opts[:to], :subject => @subject, template_name: 'basic')
  end

  def reset_password_instructions(uid, account, token, opts={})
    prepare_msg(account)
    record = User.find(uid)

    @url = prepare_url(scoped_t("#{account}.site.mailer.links.change_password"), url_for(controller: 'devise/passwords', action: 'edit', reset_password_token: token))

    @subject = scoped_t("#{account}.site.mailer.reset_password_instructions.subject")
    @body = scoped_t("#{account}.site.mailer.reset_password_instructions.body_html", :name => record.email, :url => @url)
    mail(:from => opts[:from], :to => opts[:to], :subject => @subject, template_name: 'basic')
  end

  def unlock_instructions(uid, account, token, opts={})
    record = User.find(uid)
    super(record, token, opts)
  end

  # Klass invitation emails
  def klass_invitation(account, from, to, kid, name, url)
    klass = Klass.find(kid)
    prepare_msg(account, klass.course.name)

    @url = prepare_url(scoped_t("#{account}.site.mailer.links.sign_in"), url)

    @klasses = [ klass ]
    @subject = scoped_t("#{account}.site.mailer.klass_invitation.subject")
    @body = scoped_t("#{account}.site.mailer.klass_invitation.body_html", :name => name, :url => @url,
      :course_name => klass.course.name)

    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end

  # Klass enrollment emails
  def klass_enrollment(account, from, to, klasses, url)
    @klasses = Klass.find(klasses)
    prepare_msg(account, @klasses.map{|k| k.course.name}.join(', '))
    @url = prepare_url(scoped_t("#{account}.site.mailer.links.sign_in"), url)

    @subject = scoped_t("#{account}.site.mailer.klass_enrollment.subject")
    @body = scoped_t("#{account}.site.mailer.klass_enrollment.body_html", :url => @url)

    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end

  # Update emails
  def klass_update(account, from, to, subject, body, kid)
    klass = Klass.find(kid)
    prepare_msg(account, klass.course.name)

    @url = prepare_url(scoped_t("#{account}.site.mailer.links.go_to_class"), learn_klass_url(kid))

    @subject = subject
    @body = body

    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end

  # Faculty application approved or declined
  def faculty_application(account, from, to, url, approved)
    prepare_msg(account, scoped_t("#{account}.site.mailer.faculty_application.subject"))
    @url = prepare_url(scoped_t("#{account}.site.mailer.links.sign_in"), url)

    @subject = scoped_t("#{account}.site.mailer.faculty_application.subject")
    @body = scoped_t("#{account}.site.mailer.faculty_application.#{approved ? 'approved' : 'declined'}_body_html", :url => @url)

    mail(:from => from, :to => to, :subject => @subject, template_name: 'basic')
  end
end
