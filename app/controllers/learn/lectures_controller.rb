  module Learn
  class LecturesController < BaseController
    def show
      @lecture_contents = @lecture.contents(true, staff?(current_user, @klass) || @klass.enrolled?(current_student))
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
      if @discussion
        @forum = Forum.unscoped do @discussion.forum end
        @topic = @discussion.topic
        @post = Post.new
        @topic.hit! if @topic && @klass.open?
      end
    end

    def index
    end

    def show_page
      @page = Page.scoped.find(params[:page_id])
      @lecture.log_attendance(@klass, current_student, @page)

      @mark_as_taken = true
      respond_to do |format|
        format.js { render 'show' }
      end
    end

    def show_question
      @question = Question.find(params[:question_id])
      if params[:attempt]
        case @question.kind
        when 'pick_one'
          @answer = Hash[@question.options.map do |o|
            correct = (o.option.strip == params[:attempt][@question.id.to_s] &&  o.answer_options == '1')
            [o.id, correct ? '1' : '0']
          end]
        when 'pick_many'
          @answer = Hash[@question.options.map do |o|
            correct = (o.option.strip == params[:attempt][@question.id.to_s][o.id.to_s] &&  o.answer_options == '1')
            [o.id, correct ? '1' : '0']
          end]
        else
          @answer = Hash[params[:attempt][@question.id.to_s].map do |k, v| [k.to_i, v.strip] end]
        end
        @lecture.log_attendance(@klass, current_student, @question, @answer)

        # @correct_answer = Hash[@question.options.map{|o| ["answer_#{@question.id}_#{o.id}", o.answer]}]

        case @question.kind
        when 'fill_many', 'pick_2_fill'
          @correct_answer = { "answer_#{@question.id}" => @question.options.map{|o| o.answer} }
        when 'match', 'sort'
          answers = @question.answer
          @correct_answer = Hash[answers.keys.map{|k| ["answer_#{@question.id}_#{k}", answers[k]]}]
        else
          @correct_answer = Hash[@question.options.map{|o| ["answer_#{@question.id}_#{o.id}", o.answer]}]
        end

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
