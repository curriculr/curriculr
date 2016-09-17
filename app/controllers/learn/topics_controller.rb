module Learn
  class TopicsController < BaseController
    responders :modal, :flash, :http_cache
    def index
    end

    def show
      check_access! "discussions"
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])
      @post = Post.new
      @topic.hit! if @topic && @klass.open?
      respond_with(@topic)
    end

    def new
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.new
    end

    def create
      @forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.new(topic_params)
      @topic.author = @student || current_user

      respond_with @topic do |format|
        if @topic.save
          format.js { 
            @reload_url = learn_klass_forums_url(@klass, forum: @forum.id) 
            render 'reload' 
          }
        else
          format.js { render :action => 'new' }
        end
      end
    end

    def edit
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])
    end

    def update
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])

      respond_with @topic do |format|
        if @topic.update(topic_params)
          format.html { redirect_to learn_klass_forum_topic_path(@klass, @forum, @topic) }
        else
          format.html { render :action => 'edit' }
        end
      end
    end

    def up
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])
      @post = Post.new
      respond_with @topic do |format|
        format.js {
          t_ups = JSON.parse(cookies[:"t_ups_#{current_user.id}"] || "[]")
          if t_ups.blank? || !t_ups.include?(@topic.id)
            @topic.increment!(:ups)
            t_ups << @topic.id
          end

          cookies[:"t_ups_#{current_user.id}"] = { value: JSON.generate(t_ups), expires: 48.hour.from_now }
          render 'learn/topics/show'
        }
      end
    end

    def down
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])
      @post = Post.new
      respond_with @topic do |format|
        format.js {
          t_downs = JSON.parse(cookies[:"t_downs_#{current_user.id}"] || "[]")
          if t_downs.blank? || !t_downs.include?(@topic.id)
            @topic.increment!(:downs)
            t_downs << @topic.id
          end

          cookies[:"t_downs_#{current_user.id}"] = { value: JSON.generate(t_downs), expires: 48.hour.from_now }
          render 'learn/topics/show'
        }
      end
    end

    def destroy
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:id])

      respond_with @topic do |format|
        if @topic.destroy
          format.html { redirect_to learn_klass_forums_path(@klass, @forum) }
        end
      end
    end

    private
      def topic_params
        params.require(:topic).permit(:name, :about, :points_per_post, :points_per_reply, :anonymous)
      end
  end
end
