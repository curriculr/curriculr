module Teach
  class UnitsController < BaseController
    responders :modal, :flash, :http_cache

    def show
      respond_with @unit do |format|
        format.html { render :action => :index }
        format.js { render 'show' }
      end
    end

    def index
      @units = @course.units.order('units.order').to_a
      redirect_to [:teach, @course, @units.first] unless @units.empty?
    end
    
    def new
      @unit = @course.units.new(:based_on => @course.revision.begins_on)
    end

    def edit
      based_on = @course.revision.begins_on
      if @unit.based_on != based_on
        @unit.on_date =  @unit.on_date + (based_on - @unit.based_on).to_i.days
        @unit.based_on = based_on
      end
    end

    def create
      @unit = @course.units.new(unit_params)
      @unit.save
      respond_with :teach, @course, @unit
    end

    def update
      @unit.update(unit_params)
      respond_with :teach, @course, @unit
    end

    def destroy
      @unit.destroy
      respond_with @unit do |format|
        format.html { redirect_to teach_course_units_path(@course) }
      end
    end
  
    def sort
      params[:unit].each_with_index do |id, i|
        Unit.where(:id => id).update_all(order: i + 1)
      end
      
      head :ok
    end
    
    private
      def unit_params
        params.require(:unit).permit(:course_id, :name, :about, :on_date, :based_on, :for_days, :order, :previewed)
      end
  end
end