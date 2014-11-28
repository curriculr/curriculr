module Learn
  class LecturesController < BaseController
    def show
      @lecture_contents = @lecture.contents(true)
      if @lecture_contents && @klass.open? && (@klass.enrolled?(current_student) || staff?(current_user, @klass))
        points = 0.0
        count = 0.0
        item = @lecture_contents[0]
        items = @lecture_contents

        if items.present?
          count = items.size.to_f

          @lecture.log_attendance(@klass, current_student, item, nil, count)
        end
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
      @lecture.log_attendance(@klass, current_student, @page)

      @mark_as_taken = true
      respond_to do |format|
        format.js { render 'show' }
      end
    end
    
    def show_question
      @question = Question.find(params[:question_id])
      if params[:attempt]
        @answer = Hash[params[:attempt][@question.id.to_s].map do |k, v| [k.to_i, v.strip] end]
        @lecture.log_attendance(@klass, current_student, @question, @answer)

        #params[:attempt][@question.id.to_s]
        @correct_answer = Hash[@question.options.map{|o| ["answer_#{@question.id}_#{o.id}", o.answer]}]
        @mark_as_taken = true

        @result = AssessmentAttempt.is_correct?(@question, @answer)
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
      @lecture.log_attendance(@klass, current_student, @material)
      @mark_as_taken = true
      @video = @material if @material.kind == 'video'
      respond_to do |format|
        format.html{ render 'show' }
        format.js{ render 'show' }
      end
    end
  end
end