module Teach
  class QSelectorsController < BaseController
    before_action :set_q_selector, only: [:edit, :update, :destroy]
    responders :flash, :http_cache

    def new
      @q_selector = QSelector.new(:assessment => @assessment)

      criteria = [ "course_id = #{@course.id}" ]
      criteria << "unit_id = #{@unit.id}" if @unit
      criteria << "lecture_id = #{@lecture.id}" if @lecture
      if params[:s] && params[:s] != 'all' 
        criteria << "kind like '#{params[:s]}%' "
      end

      @questions = Question.where(criteria.join(' and '))

      render 'questions/index'
    end

    def edit
    end

    def create
      @q_selector = @assessment.q_selectors.new(q_selector_params)

      respond_with @q_selector do |format|
        if @q_selector.save
          format.html { redirect_to @req_objects }
          format.js { render 'teach/questions/select' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    def destroy
      @q_selector.destroy
      respond_with @q_selector do |format|
        format.js {
          @q_selector = QSelector.new(:question_id => @q_selector.question_id)
          render 'teach/questions/select'
        }
      end
    end

    def question_bank_path(action, kind)
      url_for(:action => action, :controller => 'questions',
                  :course_id => @course.id, :unit_id => (@unit ? @unit.id : nil),
                  :lecture_id => (@lecture ? @lecture.id : nil), :s => kind )
    end

    private
      def set_q_selector
        @q_selector = QSelector.find(params[:id])
      end

      def q_selector_params
        params.require(:q_selector).permit(:assessment_id, :set, :points,
          :question_id, :kind, :questions_count, :lecture_id, :unit_id, :a_specific_question)
      end
  end
end
