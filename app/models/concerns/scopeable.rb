module Scopeable
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    
    # default_scope -> {
    #   where(account_id: Account.current_id)
    # }

		scope :scoped, -> { where(account_id: Account.current_id) }

    before_create do |model|
    	model.account_id = Account.current_id if Account.current_id.present?
    end

    before_create do |model|
      model.account_id = Account.current_id if Account.current_id.present?
    end

    before_validation do |model|
      if model.account_id.blank?
        model.account_id = Account.current_id if Account.current_id.present?
      end
    end
  end

  def account
    @account || (
      Account.current_id.present? ? Account.find(Account.current_id) : @account
    )
  end

  module ClassMethods
    def scopeable?
      true
    end
  end
end