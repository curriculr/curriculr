class AuthorizedController < ApplicationController
  before_action :load_data
  load_and_authorize_resource 
  
  private
    def load_data 
    end
    
    def current_ability
      @current_ability ||= Ability.new(current_account, current_user, current_student, @course, @klass, @assessment)
    end
end
