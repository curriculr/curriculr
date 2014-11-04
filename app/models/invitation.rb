class Invitation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :invitee
  
  validates_format_of :invitee, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\Z/i, :message => :invalid_email
  
  def persisted?
    false
  end
end
