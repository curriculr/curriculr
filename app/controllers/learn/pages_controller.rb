module Learn
  class PagesController < BaseController
    def show
      @page = Page.scoped.find(params[:id])
    end
    
    def index
    end
  end
end