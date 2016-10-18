class Student < ActiveRecord::Base
  mount_uploader :avatar, StudentAvatarUploader
  
  belongs_to :user
  has_many :enrollments, :dependent => :destroy
  validates :name, :presence => true, :if => Proc.new { |s| s.relationship != 'self' }
  validates :name, uniqueness: { :scope => [ :user_id ] }, :if => Proc.new { |s| s.relationship != 'self' }
  
  def name
    super || user.name
    # if relationship == 'self'
    #   user.name
    # else
    #   read_attribute(:name)
    # end
  end

  def email
    user.email
  end
  
  def avatar_url(account, version)
    if super(version).present?
      super(version)
    else
      user.profile.avatar_url(account, version)
      #"/images/nobody-#{version}.png"
    end
  end
end
