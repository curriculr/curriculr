module Admin 
  class BaseController < AuthorizedController
    respond_to :html, :js
  end
end