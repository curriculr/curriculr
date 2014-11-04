module Learn
  class PagesController < BaseController
    def show
      @page = Page.find(params[:id])
    end
    
    def index
    end
  end
end