module Auth
  class PasswordResetsController < ApplicationController
    def create
      user = User.scoped.find_by(email: user_params[:email])
      user.send_password_reset_instructions if user
      redirect_to auth_signin_path, :notice => t('auth.password_resets.sent')
    end

    def edit
      @user = User.find_by(password_reset_token: params[:id])
      redirect_to auth_signin_path unless @user
    end

    def update
      @user = User.find_by(password_reset_token: user_params[:password_reset_token])
      if @user
        if @user.password_reset_expired?
          redirect_to new_auth_password_reset_path, :alert => t('auth.password_resets.expired')
        elsif @user.update(user_params)
          redirect_to auth_signin_path, :notice => t('auth.password_resets.done')
        else
          render :edit
        end
      else
        redirect_to auth_signin_path
      end
    end

    private
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :password_reset_token)
      end
  end
end
