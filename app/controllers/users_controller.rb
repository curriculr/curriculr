class UsersController < AuthorizedController
  respond_to :html, :js
  before_action :require_admin, :only => [:index, :destroy]
  responders :flash, :http_cache

  def front
    if current_user
      redirect_to home_path
    else
      @q = Klass.available(current_user).search(params[:q])
      @klasses = @q.result.page(params[:page]).per(10)

      render 'front'
    end
  end

  def home
    unless current_user
      redirect_to root_path
    end
  end

  def index
    @q = User.scoped.search(params[:q])
    @users = @q.result.page(params[:page]).per(10).order(:id)

    respond_with @users
  end

  def show
    @user = User.scoped.find(params[:id])
  end

  def edit
    @user = User.scoped.find(params[:id])
  end

  def confirm
    @user = User.scoped.find(params[:id])
    @user.confirm! if @user && !@user.confirmed?

    redirect_to users_path
  end

  def update
		@user = User.scoped.find(params[:id])
		@user.active = !@user.active if params[:opr] == 'activate'

    @to_update_role = false
    if params[:opr] && t('config.role').keys.include?(params[:opr].to_sym)
      if @user.has_role? params[:opr]
        @user.remove_role params[:opr]
        AccessToken.where(:user => @user).update_all(:revoked_at => Time.zone.now) if params[:opr] == 'console'
      else
        @user.add_role params[:opr]
      end

      @to_update_role = true
    end

		respond_with @user do |format|
			format.html {
        if @user.update(user_params)
				  redirect_to (params[:opr] ? users_path : home_path)
  			else
  		  	render action: "edit"
        end
      }
  		format.js   {
        has_name = user_params[:name].present? && user_params[:name].strip.present?
        if has_name
          @user.assign_attributes(user_params) unless params[:opr]
          if @user.save(validate: false)
    			  @update_class = "usr_activate_#{@user.id}_link" if params[:opr] == 'activate'
      		  @update_class = "usr_#{params[:opr]}_#{@user.id}_link" if @to_update_role
          end
        end
        if params[:opr]
    		  render 'users'
        else
          render 'reload'
        end
			}
		end
  end

  def destroy
    @user = User.scoped.find(params[:id])
    @user.destroy

    respond_with @user do |format|
      format.html { redirect_to users_url }
      format.js   {
        @delete_class = "usr_delete_#{@user.id}_link"
        render 'users'
      }
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :email, :name, :password, :active, :time_zone,
        :profile_attributes => [
          :prefix, :avatar, :about, :nickname, :public, :locale
        ]
      )
    end
end
