module Teach
  class LecturesController < BaseController
    responders :flash, :http_cache
    
    def show
      respond_with @lecture do |format|
        format.html{ render template: 'teach/units/index' }
        format.js
      end
    end
     
    def new
      @lecture = @unit.lectures.new(:based_on => @course.revision.begins_on)
      @lecture.on_date = @unit.on_date
      @lecture.for_days = @unit.for_days
    end

    def edit
      based_on = @course.revision.begins_on
      if @lecture.based_on != based_on
        @lecture.on_date = @lecture.on_date + (based_on - @lecture.based_on).to_i.days
        @lecture.based_on = based_on
      end
    end

    def create
      @lecture = @unit.lectures.new(lecture_params)
   
      respond_with @lecture do |format|
        if @lecture.save
          format.html { redirect_to teach_course_unit_path(@course, @unit) }
        else
          format.html { render action: "new" }
        end
      end
    end
    
    def update
      respond_with @lecture do |format|
        if @lecture.update(lecture_params)
          format.html { redirect_to teach_course_unit_path(@course, @unit) }
        else
          format.html { render action: "edit" }
        end
      end
    end

    def destroy
      @lecture.destroy
      
      respond_with @lecture do |format|
        format.html { redirect_to teach_course_unit_path(@course, @unit) }
      end
    end
  
    def discuss
      @lecture.allow_discussion = !@lecture.allow_discussion
      @lecture.save
      respond_with @lecture do |format|
        format.html { redirect_to teach_course_unit_path(@course, @unit) }
      end
    end

    def delete_forum
      @lecture.forum = nil
      @lecture.allow_discussion = false
      @lecture.save
      respond_with @lecture do |format|
        format.html { redirect_to teach_course_unit_path(@course, @unit) }
      end
    end
    
    def sort
      params[:lecture].each_with_index do |id, i|
        Lecture.where(:id => id).update_all(order: i + 1)
      end
      
      render nothing: true
    end

    def content_sort
      params[:content].each_with_index do |c, i|
        id = c.split('.')
        case id.second
        when 'medium'
          Material.where(:owner_type => 'Lecture', :owner_id => @lecture.id, :medium_id => id.first).update_all(order: i + 1)
        when 'page'
          Page.where(:id => id.first).update_all(order: i + 1)
        when 'assessment'
          Assessment.where(:id => id.first).update_all(order: i + 1)
        end
      end
      
      render nothing: true
    end
  
    private    
      def lecture_params
        params.require(:lecture).permit(:unit_id, :name, :points, :about, :based_on, :on_date, :for_days, :order, :previewed)
      end
  end
end