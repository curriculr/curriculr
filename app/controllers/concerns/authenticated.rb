module Authenticated
  extend ActiveSupport::Concern

  included do
    def current_user
      @current_user ||= if cookies.signed.permanent[:auth_token]
        User.find_by(remember_token: cookies.signed.permanent[:auth_token])
      elsif cookies.signed[:auth_token]
        User.find_by(remember_token: cookies.signed[:auth_token])
      else
        nil
      end
    end

    def user_signed_in?
      !!current_user
    end
    
    def require_user
      raise CanCan::AccessDenied.new unless user_signed_in?
    end
  end

  module ClassMethods
	end
end