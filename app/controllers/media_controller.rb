class MediaController < AuthorizedController
  respond_to :html, :js
  include Mediable
end
