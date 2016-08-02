module Auth
  class SessionsController < ApplicationController
    def new
      @user = User.new
    end

    def create
      if %w(facebook google_oauth2).include?(params[:provider])
        user = User.find_for_oauth(env["omniauth.auth"], current_user)

        if user.persisted?
          cookies[:auth_token] = user.remember_token
          user.update_tracked_fields!(request)
          redirect_to user, notice: "Logged in!"
        else
          redirect_to new_user_path, notice: "Failed to signin with #{params[:provider]}!"
        end
      else
        @user = User.find_by(email: user_params[:email])

        if @user && @user.authenticate(user_params[:password])
          if @user.confirmed?
            if user_params[:remember_me]
              cookies.permanent[:auth_token] = @user.remember_token
            else
              cookies[:auth_token] = @user.remember_token
            end

            @user.update_tracked_fields!(request)

            redirect_to main_app.home_path, notice: "Successfully logged in!"
          else
            flash.now.alert = "Email not confirmed yet."
            render 'new'
          end
        else
          flash.now.alert = "Email or password is invalid."
          render 'new'
        end
      end
    end

    def destroy
      cookies.delete(:auth_token)
      redirect_to root_path, notice: "Logged out!"
    end

    private
      def user_params
        params.require(:user).permit(:email, :password, :remember_me)
      end
  end
end
