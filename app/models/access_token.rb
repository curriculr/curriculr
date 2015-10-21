class AccessToken < ActiveRecord::Base
  before_create :generate_token
  belongs_to :user

  private
    def generate_token
      begin
        self.token = SecureRandom.urlsafe_base64
      end while self.class.exists?(token: token)
    end
end
