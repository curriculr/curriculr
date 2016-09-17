module Learn
  class ForumsController < BaseController    
    def show
      check_access! "discussions"
      @forum = Forum.find(params[:id])
      #index
    end
    def index
      @forum = Forum.find(params[:forum]) if params[:forum]
      @forums = @klass.forums.where(active: true, :lecture_comments => false)
      render 'index'
    end

    private
    def forum_params
      params.require(:forum).permit(:name, :about, :active)
    end
  end
end