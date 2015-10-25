class Forum < ActiveRecord::Base
  include Actionable

  has_many :topics, :dependent => :destroy
  has_many :posts, :through => :topics

  belongs_to :course
  belongs_to :klass

  # Validations
  validates :name, :presence => true
  validates :about, :presence => true
  #validates :klass_id, :presence => true

  # scopes
  # default_scope -> { 
  #   where(:lecture_comments => false)
  # }

  scope :participated_on , ->(klass_id, student_id) {
    joins("inner join activities on actionable_id = forums.id and actionable_type = 'Forum' and forums.klass_id = activities.klass_id").
    where("activities.klass_id = :klass_id and activities.student_id = :student_id", klass_id: klass_id, student_id: student_id).
    where("forums.lecture_comments = FALSE").distinct
  }

  # callbacks
  after_create do
    log_activity('started', klass, Thread.current[:current_user]) if Thread.current[:current_user]
  end

  def course
    klass.course
  end
end
