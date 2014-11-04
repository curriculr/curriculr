module Learn
  class AssessmentsController < BaseController
    helper_method :the_path_out

    def show
      respond_to do |format|
        format.html 
      end
    end

    def index
      check_access! "assessments"
    end
  
    private
      def the_path_out
        if @lecture 
          teach_course_unit_path(@course, @lecture.unit, l: @lecture.id)
        elsif @unit
          teach_course_unit_path(@course, @unit)
        elsif @course
          teach_course_path(@course)
        end
      end
  end
end