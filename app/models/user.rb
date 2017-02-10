class User < ActiveRecord::Base
  include Scopeable
  include Authenticateable
  include Authorizable

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile

  has_many :access_tokens, :dependent => :destroy

  has_many :students, :dependent => :destroy
  has_many :blogs, :class_name => 'Page', :as => :owner

  validates :name, :email, presence: true
  validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i }, uniqueness: { :scope => :account_id }

  def first_name
    parts = name.split(/\s/)
    parts.present? ? parts.first : nil
  end

  def last_name
    parts = name.split(/\s/)
    parts.present? ? parts.last : nil
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
