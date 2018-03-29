class MiscellaneousController < ApplicationController
  respond_to :html, :js
  responders :modal, :flash, :http_cache
  
  def team
		@members = User.scoped.joins(:roles).where('users.active = TRUE and roles.name = ?', :team)
  end

  def contactus
		if params[:message]
			@message = Message.new(params[:message])
      @message.to = Rails.application.secrets.mailer[:contact_us_at]
      respond_with @message do |format|
    		if @message.valid?
      		Mailer.contactus_email(
            Rails.application.secrets.mailer[:send_from], @message.to, 
            account: current_account.slug, name: @message.name, 
            subject: @message.subject, contact_email: @message.email, 
            message: @message.content
          ).deliver_later
          
          flash[:notice] = t('flash.actions.message_sent.notice')
      		format.js { render 'reload' }
        else
          format.js { render 'contactus' }
    		end
      end
		else
			@message = Message.new
		end
  end
  
  def contactus_to_teach
		if params[:message]
			@message = Message.new(params[:message])
      @message.to = Rails.application.secrets.mailer[:contact_us_at]
      respond_with @message do |format|
    		if @message.valid?
      		Mailer.contactus_email(
            Rails.application.secrets.mailer[:send_from], @message.to, 
            account: current_account.slug, name: @message.name, 
            subject: @message.subject, contact_email: @message.email, 
            message: @message.content
          ).deliver_later
          
          flash[:notice] = t('flash.actions.request_submitted.notice')
      		format.js { render 'reload' }
        else
          format.js { render 'contactus_to_teach' }
    		end
      end
		else
			@message = Message.new
		end
  end
end
