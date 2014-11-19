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

      item = @lecture.contents(true).first
      case item
      when Material
        item.log_activity('opened', @klass, current_student, @lecture.name)
      when Page
        item.log_activity('visited', @klass, current_student, @lecture.name)
      end
    end

    def index
    end
    
    def show_page
      @page = Page.find(params[:page_id])
      @page.log_activity('visited', @klass, current_student, @lecture.name)
      @mark_as_taken = true
      respond_to do |format|
        format.js{ render 'show' }
      end
    end
    
    def show_question
      @question = Question.find(params[:question_id])
      if params[:attempt]
        @answer = Hash[params[:attempt][@question.id.to_s].map do |k, v| [k.to_i, v.strip] end]
        @question.log_activity('attempted', @klass, current_student, @lecture.name, 0, false, @answer)
        #params[:attempt][@question.id.to_s]
        @correct_answer = Hash[@question.options.map{|o| ["answer_#{@question.id}_#{o.id}", o.answer]}]
        @mark_as_taken = true
      else
        activity = @question.activity('attempted', @klass, current_student)
        @answer = activity ? activity.data : nil
      end

      respond_to do |format|
        format.js{ render 'show' }
      end
    end

    def show_assessment
      @assessment = Assessment.find(params[:assessment_id])
      respond_to do |format|
        format.js{ render 'show' }
      end
    end

    def show_material
      @material = Material.find(params[:material_id])
      @material.log_activity('opened', @klass, current_student, @lecture.name)
      @mark_as_taken = true
      @video = @material if @material.kind == 'video'
      respond_to do |format|
        format.html{ render 'show' }
        format.js{ render 'show' }
      end
    end
  end
end