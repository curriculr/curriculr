class CurrentAccount
  def initialize(app, domain)
    @app = app
    @domain = domain
  end

  def call(env)
    subdomain = if env['HTTP_HOST'].match(/^localhost/) || IPAddress.valid?(env['SERVER_NAME'])
      $site['default_account']
    else
      env['HTTP_HOST'].sub(/\.?#{@domain}.*$/,'')
    end

    if(account = Account.find_by(slug: subdomain, :active => true))
      env["curriculr.current_account"] = account
      Account.current_id = account.id
    end

    status, headers, response = @app.call(env)

    Account.current_id = nil

    [status, headers, response]
  end
end
