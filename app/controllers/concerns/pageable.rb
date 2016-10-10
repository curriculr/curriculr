module Pageable
  extend ActiveSupport::Concern

  included do
    before_action :set_page, only: [:show, :edit, :update, :destroy]
    helper_method :path_for, :the_path_out
    responders :modal, :http_cache

    def show
      respond_with @page do |format|
        format.html {render 'application/pages/show'}
        format.js {render 'application/pages/show'}
      end
    end

    def localized
      render "application/#{params[:slug]}"
    end

    def new
      @page = Page.new
      @page.tag_list.add(params[:t]) if params[:t]
      @req_objects << @page

      respond_with @page do |format|
        format.js { render 'application/pages/new' }
      end
    end

    def create
      @page = new_page(page_params)
      @req_objects << @page

      respond_with @page do |format|
        if @page.save
          format.js { render 'reload' } #redirect_to @req_objects }
        else
          format.js { render 'application/pages/new' }
        end
      end
    end

    def edit
      respond_with @page do |format|
        format.js { render 'application/pages/edit' }
      end
    end

    def update
      @page.public = !@page.public if params[:opr] == 'public'
      @page.published = !@page.published if params[:opr] == 'publish'
      respond_with @page do |format|
        if @page.update(page_params)
          format.html { redirect_to @req_objects }
      		format.js   {
            if params[:opr]
      			  @update_class = "page_public_#{@page.id}_link" if params[:opr] == 'public'
              @update_class = "page_publish_#{@page.id}_link" if params[:opr] == 'publish'

        		  render 'application/pages/update'
            else
              render 'reload'
            end
  				}
        else
          format.js { render 'application/pages/edit' }
        end
      end
    end

    def destroy
      @page.destroy
      @req_objects.pop
      respond_with @page do |format|
        format.html {
          if @req_objects.present?
            section = {}

            if @lecture
              section[:show] = 'read'
            elsif @unit
              section[:show] = 'pages'
            else
              section[:show] = 'pages'
            end

            @req_objects << section
            redirect_to @req_objects
          else
            redirect_to pages_path
          end
        }
      end
    end

    private
      def set_page
        @page = Page.scoped.find(params[:id])

        @req_objects << @page
      end

      def path_for (action, course, unit, lecture, page, params = {})
        options = {
          action: action,
          controller: 'pages',
          id: page.id
        }

        url_for options.merge(params)
      end

      def new_page(params)
        @page = current_user.blogs.new(page_params)
        @page.blog = true

        @page
      end

      def the_path_out
        pages_path
      end

      def page_params
        params.require(:page).permit(:name, :about, :slug, :blog, :html, :tag_list => []) if params[:page]
      end
  end

  module ClassMethods
	end
end
