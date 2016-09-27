module Teach
  class ForumsController < BaseController
    responders :modal, :flash, :http_cache
    
    def new
      @forum = Forum.new
    end
  
    def create
      @forum = (@klass ? @klass.forums.new(forum_params) : @course.forums.new(forum_params))
      @forum.save
      respond_with @forum
    end
  
    def edit
      @forum = Forum.find(params[:id])
    end
  
    def update
      @forum = Forum.find(params[:id])
      
      @forum.update(forum_params)
      respond_with @forum
    end
  
    def destroy
      @forum = Forum.find(params[:id])
    
      respond_with @forum do |format|
        if @forum.destroy
          format.html { 
            redirect_to @klass ? teach_course_klass_path(@course, @klass, :show => 'forums') : teach_course_path(@course, :show => 'forums') 
          }
        end
      end
    end
  
    private
      def forum_params
        params.require(:forum).permit(:name, :about, :active, :graded)
      end
  end
end