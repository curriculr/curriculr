module Scopeable
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    
    default_scope -> {
      where(account_id: Account.current_id)
    }
  end
end