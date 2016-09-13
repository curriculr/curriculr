module Auth
  class RegistrationsController < ApplicationController
    before_action :require_user, only: [:edit, :update]
    
    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          @user.send_confirmation_instructions
          format.html { redirect_to main_app.auth_signin_path, notice: t('auth.registrations.registered') }
        else
          format.html { render :new }
        end
      end
    end
    
    def edit
      @user = current_user
    end
    
    def update
      @user = current_user
      
      if @user.provider == 'identity' && !@user.authenticate(params[:user][:current_password])
        flash.now.alert = t('auth.registrations.invalid_current_password');
        render 'edit'
      elsif @user.update(user_params)
        if @user.provider != 'identity' 
          @user.provider = 'identity' 
          @user.save
        end
        
        render 'reload' #redirect_to home_path, notice: t('auth.registrations.password_changed') 
      else
        render 'edit'
      end
    end

    def confirm
      user = User.find_by(confirmation_token: params[:token])
      if user
        if user.confirmed?
          redirect_to main_app.auth_signin_path, notice: t('auth.registrations.already_confirmed') 
        else
          if user.confirmation_expired?
            @url = url_for(controller: 'auth/registrations', action: 'reconfirm')
            flash.now.alert = t('auth.registrations.confirmation_expired')
            render 'confirm'
          else
            user.confirmed_at = Time.zone.now
            user.save!(validate: false)
            redirect_to main_app.auth_signin_path, notice: t('auth.registrations.confirmed') 
          end
        end
      else
        redirect_to main_app.auth_signin_path
      end
    end

    def reconfirm
      user = User.find_by(confirmation_token: params[:token])
      if user
        if user.confirmed?
          redirect_to main_app.auth_signin_path, notice: t('auth.registrations.already_confirmed') 
        else
          if user.confirmation_expired?
            user.send_confirmation_instructions(true)
            redirect_to main_app.auth_signin_path, notice: t('auth.registrations.confirmation_sent') 
          else
            user.confirmed_at = Time.zone.now
            user.save!(validate: false)
            redirect_to main_app.auth_signin_path, notice: t('auth.registrations.confirmed') 
          end
        end
      else
        redirect_to main_app.auth_signin_path
      end
    end

    private
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
  end
end
