class User::RegistrationsController < Devise::RegistrationsController
  def authenticate_scope!
    Account.current_id = current_account.id
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end
end