module Learn
  class ForumsController < BaseController    
    def show
      check_access! "discussions"
      @forum = Forum.find(params[:id])
    end
    def index
    end

    private
    def forum_params
      params.require(:forum).permit(:name, :about, :active)
    end
  end
end