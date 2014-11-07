class User < ActiveRecord::Base  
  include Scopeable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [
            :facebook, :google_oauth2, :twitter
         ]
         
  rolify       

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile
  
  has_many :access_tokens, :dependent => :destroy
  
  #has_and_belongs_to_many :parents, :class_name => 'User'
  has_many :students
  has_many :klasses, :through => :enrollments
  has_many :blogs, :class_name => 'Page', :as => :owner

	# Validation Rules
	validates :name, :presence => true
  validates_format_of :email, with: email_regexp, allow_blank: true
  validates :email, uniqueness: { :scope => :account_id }
  def email_changed?
    false # To prevent devise from checking email uniqueness which we'll do ourselves.
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where('(provider = :provider and uid = :uid) or email = :email',
    :provider => auth.provider, :uid => auth.uid, :email => auth.info.email).first
    unless user
      user = User.create(name: auth.extra.raw_info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        account_id: Account.current_id,
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
  
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    puts access_token
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.new(name: data["name"],
        provider: access_token.provider,
        email: data["email"],
        uid: access_token.uid,
        password: Devise.friendly_token[0,20],
        avatar: data["image"]
      )
      user.skip_confirmation! 
      user.save!
    else
      if data["image"].present? and (user.provider != access_token.provider or user.uid.blank?) 
        user.update(
          provider: access_token.provider,
          uid: access_token.uid,
          avatar: data["image"]
        ) 
      end
    end
    user
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
      
      if data = session["devise.google_data"] && session["devise.google_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
  def student?
    enrollments.count > 0 ? true : false
  end
  
  def self_student
    self.students.where("relationship = 'self'").first
  end

  def anonymous?
    new_record?
  end

  
  def to_s
    name
  end
  
  def public_profile; return profile.public; end
  
  def dependents
    self.students.where("relationship <> 'self'")
  end
  
  # Scopes  
  # A callback
  before_create do |user|
    user.time_zone = Rails.application.config.time_zone
    if user.avatar.blank?
      user.avatar = "https://gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}.png?s=50"
    end
  end
  
  after_create do |user|
  	user.add_role :admin if user.id == 1
    
    Profile.create(:user_id => user.id)
    Student.create(:user_id => user.id, :relationship => 'self')
  end
  
  def activate!
     update_attributes(:active => true)
  end

end
