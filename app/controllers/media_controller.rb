class MediaController < AuthorizedController
  respond_to :html, :js
  include Mediable
  
  def play
    @video = Medium.scoped.find_by(id: params[:id], kind: 'video')
    render layout: false
  end
end
