class UsersController < AuthorizedController
  #before_action :require_no_user, :only => [:signin, :create_session]
	#before_action :require_admin_or_no_user, :only => [:new, :create]
  #before_action :require_user, :only => [:show, :edit, :update, :destroy_session]
  respond_to :html, :js
  before_action :require_admin, :only => [:index, :destroy]
  responders :flash, :http_cache

  def front
    if current_user
      home
    else
      #@user = User.new
    
      @q = Klass.available(current_user).search(params[:q])
      @klasses = @q.result.page(params[:page]).per(10)

      render 'front' 
    end
  end

  def home
    if current_user
      if current_user.has_role? :faculty
        redirect_to teach_courses_path
      else
        redirect_to learn_klasses_path
      end
    else
      redirect_to root_path 
    end
  end  
  
  def index
    @q = User.search(params[:q])
    @users = @q.result.page(params[:page]).per(10).order(:id)

    respond_with @users
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
		@user = User.find(params[:id])
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
        if @user.save
  			  @update_class = "usr_activate_#{@user.id}_link" if params[:opr] == 'activate'
    		  @update_class = "usr_#{params[:opr]}_#{@user.id}_link" if @to_update_role
        end
        
    		render 'users' 
			} 
		end
  end

  def destroy
    @user = User.find(params[:id])
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
        :email, :name, :active, :time_zone, 
        :profile_attributes => [
          :prefix, :avatar, :about, :nickname, :public
        ] 
      )
    end
end
