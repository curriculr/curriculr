module Learn 
  class MaterialsController < BaseController
    include Materializeable
    
    def show
      respond_with @material do |format|
        format.html { redirect_to @material.at_url }
        format.js
      end
    end
  end
end
