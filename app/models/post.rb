class Post < ActiveRecord::Base
  include Actionable

  belongs_to :forum, :counter_cache => true
  belongs_to :topic, :counter_cache => true, :touch => true 
  belongs_to :author, :polymorphic => true
  belongs_to :parent, :class_name => "Post", :counter_cache => true
  has_many :replies, :class_name => "Post",
    :foreign_key => "parent_id", :dependent => :destroy
  accepts_nested_attributes_for :replies, :allow_destroy => true
  
  # Validations
  validates :about, :presence => true
  validates :author, :presence => true
  
  # Default Scope
  default_scope -> {
    order  'created_at ASC'
  }
   
  # Scope to display only the last n posts. Used for "Recent Posts" display
  scope :recent, ->(c) {
    reorder('created_at desc').limit(c)
  }
  
  def author_avatar(account, version, alt_img)
    unless anonymous
      case author
      when Student
        author.avatar_url(account, version)
      when User
        author.profile.avatar_url(account, version)
      else
        alt_img
      end
    else
      alt_img
    end
  end

  def author_name
    if author.name 
      name_parts = author.name.split(/\s+/)
      count = name_parts.count
      if  count > 1
        "#{name_parts[0]} #{name_parts[count - 1][0]}."
      else
        name_parts[0]
      end
    end
  end

  def course
    forum.course
  end
  
  # Callbacks
  before_save :topic_locked?
  
  # callbacks
  after_create do |post|
    if forum.graded
      if post.parent.blank?
        post.log_activity('posted', forum.klass, author, forum, topic.points_per_post, true)
      else
        post.log_activity('replied', forum.klass, author, forum, topic.points_per_reply, true)
      end
    else
      post.log_activity(post.parent.blank? ? 'posted' : 'replied', forum.klass, author)
    end
  end
  
  # Methods
  private
    def topic_locked?
      if topic.locked?
        errors.add(:base, "That topic is locked")
        false
      end
    end
end
