class Instructor < ActiveRecord::Base
  mount_uploader :avatar, InstructorAvatarUploader
  
  belongs_to :user
  belongs_to :course
  
  attr_accessor :email

  validates :email, :role, :presence => true
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\Z/i, :message => :invalid_email
	validate :valid_user_email
  
  def valid_user_email 
    user = User.find_by(:email => self.email, :active => true)
    instructor = user.present? ? Instructor.where(user_id: user.id, course_id: course.id).first : nil
    
    errors.add :email, :already if new_record? && instructor.present?
    errors.add :email, :not_found unless user
  end
  
  def avatar_url(account, version)
    if super(version).present?
      super(version)
    else
      if account.config['use_gravatar']
        gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
        "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{InstructorAvatarUploader::VERSIONS[version]}" #"&d=#{CGI.escape(default_url)}"
      end
    end
  end
  
  # callbacks
  before_create do |instructor|
    instructor.order = (Instructor.where(course_id: instructor.course.id).maximum(:order) || 0) + 1
  end
end
