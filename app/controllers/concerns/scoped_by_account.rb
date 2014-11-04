module ScopedByAccount
  extend ActiveSupport::Concern

  included do
    prepend_around_action :scope_current_account
    helper_method :current_account
  end

  def current_account
    subdomain = request.subdomain

    if subdomain.blank? or subdomain == 'www'
      subdomain = $site['default_account']
    end

    account = Account.find_by(slug: subdomain, :active => true)
    unless account
      account = Account.find_by(slug: $site['default_account'], :active => true)
    end
    
    account.config = JSON.parse($redis.get("config.account.#{account.slug}"))
    
    #raise ActionController::RoutingError.new(:invalid_or_inactive_account) if account.blank?
    account
  end

  def scope_current_account 
    Account.current_id = current_account.id
    yield
  ensure
    Account.current_id = nil
  end
end