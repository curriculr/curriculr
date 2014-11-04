module Admin
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [:edit, :update, :destroy]
    #before_action only: :edit do Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M" end
    responders :flash, :http_cache, :collection
    
    def index
      @announcements = Announcement.all
      respond_with(@announcements)
    end

    def hide
        ids = [ params[:id], *cookies.signed[:hidden_announcement_ids] ]
        cookies.permanent.signed[:hidden_announcement_ids] = ids
        respond_with do |format|
          format.html { redirect_to :back }
          format.js
        end
    end
      
    def new
      @announcement = Announcement.new
      respond_with(@announcement)
    end

    def edit
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.user = current_user
      @announcement.save
      respond_with(:admin, @announcement)
    end

    def update
      @announcement.update(announcement_params)
      respond_with(:admin, @announcement)
    end

    def destroy
      @announcement.destroy
      respond_with(:admin, @announcement)
    end

    private
      def set_announcement
        @announcement = Announcement.find(params[:id])
      end

      def announcement_params
        params.require(:announcement).permit(:message, :starts_at, :ends_at, :suspended)
      end
  end
end
