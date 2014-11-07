class MiscellaneousController < ApplicationController
  respond_to :html, :js
  responders :flash, :http_cache
  
  def team
		@members = User.joins(:roles).where('users.active = TRUE and roles.name = ?', :team)
  end

  def contactus
		if params[:message]
			@message = Message.new(params[:message])
      @message.to = current_account.config['mailer']['contact_us_at']
      respond_with @message do |format|
    		if @message.valid?
      		Mailer.contactus_email(current_account, @message).deliver
      		format.html { redirect_to root_path }
    		end
      end
		else
			@message = Message.new
		end
  end
end
