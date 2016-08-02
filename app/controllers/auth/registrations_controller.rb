module Auth
  class RegistrationsController < ApplicationController
    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)


      respond_to do |format|
        if @user.save
          @user.send_confirmation_instructions
          format.html { redirect_to main_app.auth_signin_path }
        else
          format.html { render :new }
        end
      end
    end

    def confirm
      # http://localhost:3000/auth/J1NkG6=LgtQFIb4LoX8bghA/confirm
      user = User.find_by(confirmation_token: params[:token])
      if user
        if user.confirmed?
          redirect_to main_app.auth_signin_path, notice: "Already confirmed. Just login."
        else
          if user.confirmation_expired?
            redirect_to main_app.auth_signin_path, notice: "Confirmation expired. Reconfirmation needed."
          else
            user.confirmed_at = Time.zone.now
            user.save!(validate: false)
            redirect_to main_app.auth_signin_path, notice: "Successfully confirmed email. You may now login."
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
          redirect_to main_app.auth_signin_path, notice: "Already confirmed. Just login."
        else
          if user.confirmation_expired?
            @user.send_confirmation_instructions(true)
            redirect_to main_app.auth_signin_path, notice: "Confirmation sent."
          else
            user.confirmed_at = Time.zone.now
            user.save!(validate: false)
            redirect_to main_app.auth_signin_path, notice: "Successfully confirmed email. You may now login."
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
