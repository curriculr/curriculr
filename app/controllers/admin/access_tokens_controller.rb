module Admin 
  class AccessTokensController < BaseController
    before_action :set_access_token, only: [:revoke, :destroy]
    responders :flash, :http_cache
    
    def create
      @user = User.scoped.find(params[:user_id])
      @access_token = @user.access_tokens.new
      @access_token.scope = :all 
      @access_token.save
      
      respond_with @access_token do |format|
        format.html { redirect_to @user}
      end
    end

    def revoke
      @access_token.update(:revoked_at => @access_token.revoked_at.nil? ? Time.zone.now : nil)
      respond_with @access_token do |format|
        format.html { redirect_to @user}
      end
    end

    def destroy
      @access_token.destroy
      respond_with @access_token do |format|
        format.html { redirect_to @user}
      end
    end

    private
      def set_access_token
        @user = User.scoped.find(params[:user_id])
        @access_token = AccessToken.find(params[:id])
      end

      def access_token_params
        if params[:access_token].present?
          params.require(:access_token).permit(:user_id, :token, :scopes, :expires_in)
        end
      end
  end
end  