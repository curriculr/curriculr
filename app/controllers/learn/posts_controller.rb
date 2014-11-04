module Learn
  class PostsController < BaseController 
    before_action :set_topic, only: [:new, :create, :edit, :update, :destroy, :up, :down]
    responders :flash, :http_cache
    
    def new
      @post = Post.new
    
      if params[:quote]
        quote_post = Post.find(params[:quote])
        if quote_post
          @post.about = quote_post.about
        end
      end
    end
  
    def create
      parent = Post.find(params[:post_id]) if params[:post_id] 
    
      if params[:post_id] 
        @post = parent.replies.new(post_params)
        @post.topic = @topic
      else
        @post = @topic.posts.new(post_params)
      end
    
      @post.forum = @forum
      @post.author = @student || current_user

      respond_with @post do |format|
        if @post.save
          @post = Post.new if @lecture 
          format.html { 
            redirect_to learn_klass_forum_topic_path(@klass, @forum, @topic) 
          }
          format.js { render 'learn/topics/show' if @lecture }
        else
          format.html { 
            render 'learn/topics/show'
          }
          format.js { render 'learn/topics/show' if @lecture }
        end
      end
    end
  
    def edit
      @post = Post.find(params[:id])
    end
  
    def update
      @post = Post.find(params[:id])

      respond_with @post do |format|
        if @post.update(post_params)
          format.html { redirect_to learn_klass_forum_topic_path(@klass, @forum, @topic) }
        end
      end
    end
  
    def up
      @post = Post.find(params[:id])
      respond_with @post do |format|
        format.js { 
          p_ups = JSON.parse(cookies[:"p_ups_#{current_user.id}"] || "[]")
          if p_ups.blank? or !p_ups.include?(@post.id)
            @post.increment!(:ups)
            p_ups << @post.id
          end
          
          @post = Post.new
          cookies[:"p_ups_#{current_user.id}"] = { value: JSON.generate(p_ups), expires: 48.hour.from_now }
          render 'learn/topics/show'
        }
      end
    end
    
    def down
      @post = Post.find(params[:id])
      respond_with @post do |format|
        format.js { 
          p_downs = JSON.parse(cookies[:"p_downs_#{current_user.id}"] || "[]")
          if p_downs.blank? or !p_downs.include?(@post.id)
            @post.increment!(:downs)
            p_downs << @post.id
          end
          
          @post = Post.new
          cookies[:"p_downs_#{current_user.id}"] = { value: JSON.generate(p_downs), expires: 48.hour.from_now }
          render 'learn/topics/show'
        }
      end
    end
    
    def destroy
      @post = Post.find(params[:id])
    
      respond_with @post do |format|
        if @post.destroy
          format.html { 
            if @lecture
              redirect_to learn_klass_lecture_path(@klass, @lecture, :show_comments => true)
            else
              redirect_to learn_klass_forum_topic_path(@klass, @forum, @topic) 
            end
          }
        end
      end
    end
  
    private
      def set_topic
        if @lecture 
    		  @forum = Forum.unscoped.find(params[:forum_id])
        else
          @forum = Forum.find(params[:forum_id])
        end
      
        @topic = Topic.find(params[:topic_id])
      end
      
      def post_params
        params.require(:post).permit(:about, :anonymous)
      end
  end
end