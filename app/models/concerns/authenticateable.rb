module Authenticateable
  extend ActiveSupport::Concern

  included do
    has_secure_password

    attr_accessor :remember_me

    validates :password, presence: true, confirmation: true, length: { minimum: 8 }

    before_create do |user|
      generate_token(:remember_token)
      generate_token(:confirmation_token)
    end

    def password_reset_expired?
      self.password_reset_sent_at < (Rails.application.secrets.auth['password_reset_within_hours'] || 12).hours.ago
    end

    def send_password_reset_instructions
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!(validate: false)
      Mailer.password_reset_instructions(self.id, self.account.slug, self.password_reset_token, to: self.email).deliver_later
    end

    def confirmed?
      confirmed_at.present?
    end

    def confirmation_expired?
      self.confirmation_sent_at < (Rails.application.secrets.auth['confirm_within_hours'] || 48).hours.ago
    end

    def send_confirmation_instructions(new_token = false)
      self.generate_token(:confirmation_token) if new_token

      self.confirmation_sent_at = Time.zone.now
      self.confirmed_at = nil

      self.save!(validate: false)
      
      Mailer.confirmation_instructions(self.id, self.account.slug, self.confirmation_token, to: self.email).deliver_later
    end

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

    def update_tracked_fields!(request)
      old_current, new_current = self.current_signin_at, Time.zone.now
      self.last_signin_at     = old_current || new_current
      self.current_signin_at  = new_current

      old_current, new_current = self.current_signin_ip, request.remote_ip
      self.last_signin_ip     = old_current || new_current
      self.current_signin_ip  = new_current

      self.signin_count ||= 0
      self.signin_count += 1

      save!(validate: false)
    end
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
          password: SecureRandom.hex[0,11],
          avatar: auth.info.image,
          confirmed_at: Time.zone.now
        )

        user.save!
      else
      	if auth.info.image.present? && (user.provider != auth.provider || user.uid.blank?)
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
