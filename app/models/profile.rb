class Profile < ActiveRecord::Base
  mount_uploader :avatar, UserAvatarUploader

  belongs_to :user

  def avatar_url(account, version)
    if super(version).present?
      super(version)
    else
      user.avatar || "/images/nobody-#{version}.png"
    end
  end
end
