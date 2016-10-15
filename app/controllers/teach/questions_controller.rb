module Teach
  class QuestionsController < BaseController
    responders :modal, :flash, :http_cache

    def index
      criteria = [ "questions.course_id = #{@course.id}" ]
      query = Question
      if params[:a]
        @assessment = Assessment.find(params[:a])
        @q_selector = QSelector.new if @assessment

        query = query.tagged_with('survey', :on => :banks, :exclude => @assessment.kind != 'survey')
      end

      if params[:b]
        @bank = params[:b]
        query = query.tagged_with(@bank, :on => :banks)
      end

      if @unit
        query = query.joins(:unit).order('units.order')
        criteria << "questions.unit_id = #{@unit.id}"
      else
        criteria << "unit_id is null"
      end

      if @lecture
        query = query.joins(:lecture).order('lectures.order')
        criteria << "questions.lecture_id = #{@lecture.id}" if @lecture
      else
        criteria << "lecture_id is null"
      end

      if params[:s] && params[:s] != 'all' 
        criteria << "kind like '#{params[:s]}%' "
        #else
        #criteria << "kind like 'fill%' "
      end

      @q = query.where(criteria.join(' and ')).search(params[:q])
      @questions = @q.result.page(params[:page]).per(10)
    end

    def new
      @question = Question.new(:course => @course,
        :unit => @unit,
        :lecture => @lecture,
        :kind => params[:s] ? params[:s] : :fill_one)

      @question.bank_list = [ params[:b] ? params[:b] : 'main' ]
      @question.options.build
    end

    def preview
      respond_with @question do |format|
        format.js
      end
    end

    def edit
      @unit = @question.unit
      @lecture = @question.lecture
    end

    def create
      @question = Question.new(question_params)

      respond_with @question do |format|
        if @question.save
          bank = @question.bank_list.first
          format.js {
            render 'reload' #redirect_to view_context.question_bank_path(:index, @question.kind.split('_').first, nil, bank)
          }
        else
          format.js { render action: 'new' }
        end
      end
    end

    def update
      respond_with @question do |format|
        if @question.update(question_params)
          bank = @question.bank_list.first
          format.js {
            render 'reload' #redirect_to view_context.question_bank_path(:index, @question.kind.split('_').first, nil, bank)
          }
        else
          format.js { render action: 'edit' }
        end
      end
    end

    def include_in_lecture
      if @question && @question.lecture
        @question.include_in_lecture = !@question.include_in_lecture
        @question.save!(validate: false)
      end

      head :ok
    end

    def sort_option
      params[:option].each_with_index do |id, i|
        @question.options.where(:id => id).update_all(order: i + 1)
      end

      head :ok
    end

    def destroy
      @question.destroy
      respond_with @question do |format|
        format.html { redirect_to view_context.question_bank_path(:index, @question.kind.split('_').first) }
      end
    end

    private
      def question_params
        params.require(:question).permit(:course_id, :unit_id, :lecture_id, :kind, :question,
          :hint, :explanation, :include_in_lecture, :tag_list => [], :bank_list => [],
          :options_attributes => [
            :id, :option, :answer, :answer_options, :_destroy
        ])
      end
  end
end
