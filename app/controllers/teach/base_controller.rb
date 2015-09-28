module Teach
  class BaseController < AuthorizedController
    respond_to :html, :js

    private
      def load_data
        set_course
      end

      def set_course
        @course ||= load_req_object(Course, 'teach/courses', :course_id)

        if @course
          @page_header = @course.name

          @unit = load_req_object(Unit, 'teach/units', :unit_id)
          @lecture = load_req_object(Lecture, 'teach/lectures', :lecture_id)
          @question = load_req_object(Question, 'teach/questions', :question_id)
          @assessment = load_req_object(Assessment, 'teach/assessments', :assessment_id)
          @page = load_req_object(Page, 'teach/pages', :page_id)

          @klass = load_req_object(Klass, 'teach/klasses', :klass_id)

          if @course
            I18n.locale = @course.locale || I18n.locale
          end
        end
      end
  end
end
