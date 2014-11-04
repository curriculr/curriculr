class PagesController < AuthorizedController
  respond_to :html, :js
  include Pageable
    
  def index
    if current_user
      if current_user.has_role? :admin
        @q = Page.where(:owner_type => 'User').search(params[:q])
      else
        @q = Page.where(:owner_type => 'User', :owner_id => current_user.id).search(params[:q])
      end 
    else
      @q = Page.none.search(params[:q])
    end
    
    @pages = @q.result.page(params[:p]).per(10)
    
    respond_with @pages do |format|
      format.html  { render 'application/pages/index' }
      format.js { render 'application/pages/index' }
    end
  end
  
  def blogs
    @blogs = Page.blogs.all.page(params[:page]).per(10)
    render 'application/pages/blogs'
  end
end
