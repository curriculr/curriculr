class Update < ActiveRecord::Base
  belongs_to :course
  belongs_to :unit
  belongs_to :lecture
  belongs_to :klass
  
  # Validation Rules
  validates :to, :body, :presence => true
  validates :subject, :presence => true, if: :www_or_email?
  validate :no_kind?

  def www?
     www
  end
  def no_kind?
    if !www and !email
      errors.add :www, I18n.t('errors.models.update.kind.no_kind')
    end
  end
  
  def www_or_email?
     www or email
  end
  
  default_scope -> {
    order('updates.updated_at DESC')
  }
  
  scope :sent, ->(klass, options = {}) {
    criteria = "updates.active = TRUE and updates.sent_at is not NULL and klasses.id = :klass_id "
    criteria << " and updates.www = TRUE" if options[:www]
    criteria << " and updates.email = TRUE" if options[:email]
    criteria << " and updates.sms = TRUE" if options[:sms]
    
    joins(:klass).where(criteria, :klass_id => klass.id)
  }
end
