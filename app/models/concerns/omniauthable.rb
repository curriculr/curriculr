module Omniauthable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
	  def find_for_oauth(auth, signed_in_resource = nil)
      email = auth.info.email 
      user = User.scoped.where(:email => email).first if email

      unless user
        user = User.new(
        	provider: auth.provider,
          name: auth.extra.raw_info.name,
          uid:auth.uid,
          email: email,
          password: Devise.friendly_token[0,20],
          avatar: auth.info.image
        )
        user.skip_confirmation!
        user.save!
      else
      	if auth.info.image.present? and (user.provider != auth.provider or user.uid.blank?) 
	        user.update(
	          provider: auth.provider,
	          uid: auth.uid,
	          avatar: auth.info.image
	        ) 
	      end
      end

	    user
	  end
	end
end