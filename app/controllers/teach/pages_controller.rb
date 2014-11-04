module Teach
  class PagesController < BaseController
    include Pageable
    
    def set_page
      @page = Page.find(params[:id])
      @lecture = @page.owner if @page.owner.is_a?(Lecture)
      @unit
    end
    
    def path_for (action, course, unit, lecture, page, params = {})
      options = {
        action: action,
        controller: 'teach/pages',
        course_id: course.id, 
        unit_id: (unit ? unit.id : nil),
        lecture_id: (lecture ? lecture.id : nil),
        id: page.id
      }
      
      url_for options.merge(params)
    end
    
    def new_page(params)
      if @lecture
        @page = @lecture.pages.new(page_params)
      elsif @unit
        @page = @unit.pages.new(page_params)
      elsif @course
        @page = @course.pages.new(page_params)
      end
    end
    
    def the_path_out
      if @lecture 
        teach_course_unit_lecture_path(@course, @unit, @lecture, :show => 'read')
      elsif @unit
        teach_course_unit_path(@course, @unit, :show => 'pages')
      elsif @course
        teach_course_path(@course, :show => @course.syllabus.id == @page.id ? 'syllabus' : 'pages')
      end
    end
  end
end