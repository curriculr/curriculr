module Materializeable
  extend ActiveSupport::Concern

  included do
    helper_method :path_for, :the_path_out
    responders :flash

    def show
      redirect_to @material.at_url
    end

    def new
      if params[:m]
        redirect_to new_teach_course_medium_path(@course, s: params[:s], m: [
          @course.id, @unit.present? ? @unit.id : 0, @lecture.present? ? @lecture.id : 0,
          params[:t] ? params[:t] : 0 ].join(','))
      else
        @material = Material.new(:kind => params[:s])
        @req_objects << @material

        @q = @course.media.where(:kind => view_context.to_medium_kind(params[:s])).order('created_at desc').search(params[:q])
        @media =  @q.result.page(params[:page]).per(10)

        render 'application/media/index'
      end
    end

    def create
      section = {}
      if @lecture
        @material = @lecture.materials.new(material_params)
      elsif @unit
        @material = @unit.materials.new(material_params)
      else
        @material = @course.materials.new(material_params)
      end

      @req_objects << @material
      if @material.save
        @req_objects.pop
        respond_with @material do |format|
          format.html { redirect_to @req_objects }
          format.js {}
        end
      end
    end

    def destroy
      @material = Material.find(params[:id])
      @material.destroy
      respond_with @material do |format|
        format.html {
          redirect_to @req_objects
        }
      end
    end

    private
      def material_params
        params.require(:material).permit(:medium_id, :kind, :tag_list)
      end
  end

  module ClassMethods
	end
end
