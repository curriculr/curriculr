module Learn
  class AttemptsController < BaseController
    def new
      util = AssessmentAttempt.new(@klass, @student, @assessment)
      @attempt = util.build 
    
  		respond_to do |format|
        format.html { render 'show' }
        format.js { render 'invideo' }
      end
    end
  
    def create
      util = AssessmentAttempt.new(@klass, current_student, @assessment, @attempt, request[:attempt])
      is_to_save = (params[:commit] == t('activerecord.actions.save'))
      util.score(params, is_to_save)
    
      if is_to_save
        flash.now[:notice] = t('flash.actions.save_attempt.notice')
      else
        flash.now[:notice] = t('flash.actions.submit_attempt.notice')
      end
    
  		respond_to do |format|
        format.html { 
          if @assessment.kind == 'survey' and 'on_enroll'.in?(@assessment.event_list)
            redirect_to learn_klass_path(@klass)
          else
            render 'show'
          end
        }
        format.js { render 'invideo' }
      end
    end

    def show_answer
  		respond_to do |format|
        format.html {
          attempt_params = {}

          @attempt.questions = []
          @attempt.test.each do |t|
            question = Question.find(t[:q])
            if question.kind == 'pick_one'
              t[:t].each do |o, a|
                if a == '1'
                  option = question.options.find(o)
                  attempt_params[t[:q].to_s] = option.option
                end
              end
            else
              attempt_params[t[:q].to_s]  = Hash[t[:t].map{|o,a| 
                if question.kind == 'pick_many'
                  if a == '1'
                    option = question.options.find(o)
                    [o.to_s, option.option]
                  end
                else
                  [o.to_s, a.to_s]
                end
              }]
            end
          end
        
          util = AssessmentAttempt.new(@klass, current_student, @assessment, @attempt, attempt_params)
          util.grade(@attempt.test)
          render 'answer'
        }
      
      	format.js { 
          @question = Question.find(params[:question_id])
          @answer = Hash[@question.options.map{|o| ["answer_#{@question.id}_#{o.id}", o.answer]}]
        
          render 'attempts' 
  			} 
  		end
    end
  
    private
      def attempt_params
        params.require(:attempt).permit()
      end
  end
end