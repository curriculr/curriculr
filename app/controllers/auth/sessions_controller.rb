module Auth
  class SessionsController < ApplicationController
     before_action :require_user, only: [:destroy]
    def new
      @user = User.new
    end

    def create
      if %w(facebook google_oauth2).include?(params[:provider])
        user = User.find_for_oauth(env["omniauth.auth"], current_user)

        if user.persisted?
          cookies.signed[:auth_token] = user.remember_token
          user.update_tracked_fields!(request)
          redirect_to user, notice: t('auth.sessions.signed_in')
        else
          redirect_to main_app.auth_signup_path, alert: t('auth.sessions.unable_to_signin', provider: params[:provider])
        end
      else
        @user = User.scoped.find_by(email: user_params[:email])

        if @user && @user.authenticate(user_params[:password])
          if @user.confirmed?
            if user_params[:remember_me] == '1'
              cookies.signed.permanent[:auth_token] = @user.remember_token
            else
              cookies.signed[:auth_token] = @user.remember_token
            end

            @user.update_tracked_fields!(request)

            redirect_to main_app.home_path, notice: t('auth.sessions.signed_in')
          else
            flash.now.alert = t('auth.sessions.not_confirmed')
            render 'new'
          end
        else
          flash.now.alert = t('auth.sessions.invalid_email_or_password')
          render 'new'
        end
      end
    end

    def destroy
      cookies.delete(:auth_token)
      redirect_to main_app.auth_signin_path, notice: t('auth.sessions.signed_out')
    end

    private
      def user_params
        params.require(:user).permit(:email, :password, :remember_me)
      end
  end
end
