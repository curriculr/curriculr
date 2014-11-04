module Mediable
  extend ActiveSupport::Concern
  
  included do
    before_action :set_medium, only: [:show, :edit, :update, :destroy]
    helper_method :the_path_out, :the_form_path, :the_material_path_out
    responders :flash, :http_cache
  end

  def index
    if params[:m]
      @material = Material.new(:kind => params[:s])
      @req_objects << @material
    end
    
    kind = params[:s] ? params[:s] : 'video'
    if @course
      @q = @course.media.where(:kind => kind).order('created_at desc').search(params[:q])
    else
      @q = Medium.where(:course_id => nil, :kind => kind).order('created_at desc').search(params[:q])
    end
    
    @media =  @q.result.page(params[:page]).per(10)
    
    respond_with @media do |format|
      format.html { render 'application/media/index' }
      format.js { render 'application/media/index' }
    end
  end

  def show
    redirect_to @medium.at_url
  end

  def new
    @medium = Medium.new(:kind => params[:s], :m => params[:m])
    @medium.is_a_link = !current_account.config['allow_file_upload']
    respond_with @medium do |format|
      format.html {render 'application/media/new'}
    end
  end

  def edit
    @medium.is_a_link = @medium.path.blank?
    
    respond_with @medium do |format|
      format.html {render 'application/media/edit'}
    end
  end

  def update
    @medium.is_a_link = @medium.path.blank?
    if @medium.is_a_link
      @medium.content_type = "link/#{medium_params[:source]}"
    end
    
    respond_with @medium do |format|
      if @medium.update(medium_params)
        format.html { redirect_to the_path_out(s: @medium.kind) }
      else
        format.html { render 'application/media/edit' }
      end
    end
  end

  def create
    if @course
      @medium = @course.media.new(medium_params)
    else
      @medium = Medium.new(medium_params)
    end
  
    if @medium.is_a_link
      @medium.content_type = "link/#{medium_params[:source]}"
    end

    respond_with @medium do |format|
      if @medium.save
        format.html { 
          if @medium.m.present?
            path_ids = @medium.m.split(',')
            material_params = { :medium_id => @medium.id, :kind => @medium.kind, :tag_list => path_ids[3] != '0' ? path_ids[3] : nil }
            @unit = path_ids[1] != '0' ? @course.units.find(path_ids[1].to_i) : nil
            @lecture = path_ids[2] != '0' ? @unit.lectures.find(path_ids[2].to_i) : nil
            if @lecture
              @material = @lecture.materials.create(material_params)
            elsif @unit
              @material = @unit.materials.create(material_params)
            else
              @material = @course.materials.create(material_params)
            end
            
            if @lecture or @unit
              redirect_to [:teach, @course, @unit]
            else
              redirect_to [:teach, @course]
            end
          else
            redirect_to the_path_out(s: @medium.kind) 
          end
        }
      else
        format.html { render 'application/media/new' }
      end
    end
  end

  def destroy
    @medium.destroy
    respond_with @medium do |format|
      format.html { redirect_to the_path_out(s: params[:s]) }
    end
  end

  private
  def set_medium
    @medium = Medium.find(params[:id])
  end
  
  def the_form_path
    [@medium]
  end
  
  def the_path_out(params={})
    media_path(params)
  end
  
  def the_material_path_out(kind, m)
    path_ids = m.split(',')
    url_for :action => :new, :controller => 'teach/materials', :course_id => @course.id, 
      :unit_id => path_ids[1] != '0' ? path_ids[1].to_i : nil, 
      :lecture_id => path_ids[2] != '0' ? path_ids[2].to_i : nil,
      :s => kind, :t => path_ids[3] != '0' ? path_ids[3]: nil
  end
  
  def medium_params
    params.require(:medium).permit(:kind, :url, :path, :name, :is_a_link, :source, :caption, :copyrights, :m, :tag_list => [])
  end
end