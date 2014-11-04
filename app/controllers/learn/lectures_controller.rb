module Learn
  class LecturesController < BaseController
    def show
      if @enrollment and current_user and @klass.open? 
        @lecture.log_activity('attended', @klass, @enrollment.student, @lecture.name, @lecture.points)
      end
      
      @discussion = @lecture.discussion(@klass)
      @forum = Forum.unscoped do @discussion.forum end
      @topic = @discussion.topic
      @post = Post.new
      @topic.hit! if @topic && @klass.open?
    end

    def index
    end
    
    def show_page
      @page = Page.find(params[:page_id])
      respond_to do |format|
        format.js{ render 'show' }
      end
    end
    
    def show_material
      @material = Material.find(params[:material_id])

      respond_to do |format|
        format.js{ render 'show' }
      end
    end
  end
end