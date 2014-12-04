module Teach 
  class MediaController < BaseController
    respond_to :html, :js, :json
    
    include Mediable
    
    private
    def the_form_path
      [:teach, @course, @medium]
    end
  
    def the_path_out(params = {})
      teach_course_media_path(@course, params)
    end
  end
end