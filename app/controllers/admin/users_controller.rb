module Admin
  class UsersController < BaseController
    responders :flash, :http_cache, :collection
    
    def new
      @user = User.new
      respond_with(@user)
    end

    def create
      @user = User.new(user_params)
      @user.skip_confirmation!
      @user.save
      respond_with(@user)
    end
  
    private
      def user_params
        params.require(:user).permit(
          :email, :name, :password, :password_confirmation
        )
      end
  end
end