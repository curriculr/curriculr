class Invitation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :invitee
  
  validates_format_of :invitee, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i, :message => :invalid_email
  
  def persisted?
    false
  end
end
