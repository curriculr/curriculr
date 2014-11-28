class Topic < ActiveRecord::Base
  include Actionable
  
  has_many :posts, :dependent => :destroy
  belongs_to :forum, :counter_cache => true
  belongs_to :author, :polymorphic => true

  # Validations
  validates :name,    :presence => true
  validates :about,   :presence => true, :on => :create
  validates :author,    :presence => true
  validates :points_per_post, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :points_per_reply, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
  
  # Scopes
  default_scope -> { 
    order 'sticky DESC, updated_at DESC'
  }
  
  # callbacks
  after_create do |topic|
    topic.log_activity('started_discussion', forum.klass, author, forum)
  end
  
  # Methods
  def hit!
    self.class.increment_counter :hits, id
  end
  
  def course
    forum.course
  end
  
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
end
