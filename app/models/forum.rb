class Forum < ActiveRecord::Base
  include Actionable
  
  has_many :topics, :dependent => :destroy
  has_many :posts, :through => :topics
  
  belongs_to :klass
  
  # Validations
  validates :name, :presence => true
  validates :about, :presence => true
  validates :klass_id, :presence => true
  
  # scopes
  default_scope -> { 
    where(:lecture_comments => false)
  }
  
  # callbacks
  after_create do
    log_activity('started', klass, Thread.current[:current_user], name) if Thread.current[:current_user]
  end
  
  def course
    klass.course
  end
end