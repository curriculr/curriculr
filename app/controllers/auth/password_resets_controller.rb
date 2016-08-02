module Auth
  class PasswordResetsController < ApplicationController
    def create
      user = User.find_by(email: user_params[:email])
      user.send_password_reset_instructions if user
      redirect_to auth_signin_path, :notice => "Email sent with password reset instructions."
    end

    def edit
      @user = User.find_by(password_reset_token: params[:id])
      redirect_to auth_signin_path, notice: 'Invalid token' unless @user
    end

    def update
      @user = User.find_by(password_reset_token: user_params[:password_reset_token])
      if @user && @user.password_reset_expired?
        redirect_to new_password_reset_path, :alert => "Password reset has expired."
      elsif @user && @user.update_attributes(user_params)
        redirect_to auth_signin_path, :notice => "Password has been reset! Login"
      else
        render :edit
      end
    end

    private
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
  end
end
