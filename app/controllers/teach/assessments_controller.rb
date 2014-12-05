module Teach
  class AssessmentsController < BaseController
    helper_method :the_path_out
    responders :flash, :http_cache
    
    def show
      respond_with(@assessment)
    end
  
    def preview
      @questions = @assessment.questions
      
      respond_with(@assessment)
    end

    def new
      @assessment = Assessment.new(:course => @course, :unit => @unit, 
        :lecture => @lecture, :based_on => @course.revision.begins_on, :kind => params[:t])
      #@assessment.tag_list.add(params[:t]) if params[:t]
      respond_with(@assessment)
    end
  
    def edit
      based_on = @course.revision.begins_on
      if @assessment.based_on != based_on
        @assessment.from_datetime = @assessment.from_datetime + (based_on - @assessment.based_on).to_i.days
        if @assessment.to_datetime.present?
          @assessment.to_datetime = @assessment.to_datetime + (based_on - @assessment.based_on).to_i.days
        end
        
        @assessment.based_on = based_on
      end
      
      respond_with(@assessment)
    end
  
    def create
      @assessment = Assessment.new(assessment_params)
    
      respond_with @assessment do |format|
        if @assessment.save
          format.html { redirect_to [@req_objects, @assessment].flatten }
        else
          format.html { render action: "new" }
        end
      end
    end

    def update
      @assessment.ready = !@assessment.ready if params[:opr] == 'ready'
      respond_with @assessment do |format|
        if @assessment.update(assessment_params)
          format.html { redirect_to @req_objects }
          format.js   { 
            @update_class = "assessment_ready_#{@assessment.id}_link" if params[:opr] == 'ready'
          }
        else
          format.html { render action: assessment_params[:q_selectors_attributes].present? ? "show" : "edit" }
        end
      end
    end
  
    def sort_q_selector
      params[:q_selector].each_with_index do |id, i|
        @assessment.q_selectors.where(:id => id).update_all(order: i + 1)
      end
      
      render nothing: true
    end
    
    def destroy
      @assessment.destroy
      @req_objects.pop
      respond_with @assessment do |format|
        format.html { redirect_to the_path_out}
      end
    end
  
    private
      def the_path_out
        if @lecture 
          teach_course_unit_lecture_path(@course, @lecture.unit, @lecture, show: 'assess')
        elsif @unit
          teach_course_unit_path(@course, @unit, show: 'assessments')
        elsif @course
          teach_course_path(@course, show: @assessment.kind == 'survey' ? 'surveys' : 'assessments')
        end
      end
  
      def assessment_params
        params.require(:assessment).permit(:course_id, :unit_id, :lecture_id, :name, 
          :about, :kind, :allowed_attempts, :after_deadline, :droppable_attempts, 
          :multiattempt_grading, :show_answer, :penalty, :invideo_id, :ready,
          :invideo_at, :based_on, :from_datetime, :to_datetime, :event_list, :tag_list => [], 
          :q_selectors_attributes => [
            :id, :set, :points, :order, :kind, :questions_count, :lecture_id, :unit_id, :_destroy, {:tags => []}
          ])
      end
  end
end