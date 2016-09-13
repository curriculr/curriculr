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
      # respond_with @forum do |format|
      #   if @forum.save
      #     format.html {
      #       redirect_to @klass ? teach_course_klass_path(@course, @klass, :show => 'forums') : teach_course_path(@course, :show => 'forums')
      #     }
      #   else
      #     format.html { render :action => 'new' }
      #   end
      # end
    end
  
    def edit
      @forum = Forum.find(params[:id])
    end
  
    def update
      @forum = Forum.find(params[:id])
      
      @forum.update(forum_params)
      respond_with @forum
      # respond_with @forum do |format|
      #   if @forum.update(forum_params)
      #     format.html {
      #       redirect_to @klass ? teach_course_klass_path(@course, @klass, :show => 'forums') : teach_course_path(@course, :show => 'forums')
      #     }
      #   else
      #     format.html { render :action => 'edit' }
      #   end
      # end
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