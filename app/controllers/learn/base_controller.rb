module Learn
  class BaseController < AuthorizedController
    respond_to :html, :js

    private
      def load_data
        set_klass
      end
      
      def set_klass
        @klass ||= load_req_object(Klass, 'learn/klasses', :klass_id)

        if @klass
          @page_header = @klass.course.name
          @lecture = load_req_object(Lecture, 'learn/lectures', :lecture_id)
          @assessment = load_req_object(Assessment, 'learn/assessments', :assessment_id)
          @attempt = load_req_object(Attempt, 'learn/attempts', :attempt_id)

          @student = current_student
    			@enrollment = @klass.enrollments.where(:student_id => @student.id, :active => true).first if @student.present?

          if @klass
            I18n.locale = @klass.course.locale || I18n.locale
          end
        end
      end
  end
end
