ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module SignInHelper
  def sign_in_as(user)
    cookies[:auth_token] = generate_signed_cookie_value(user.remember_token)
  end
  
  def sign_out
    cookies[:auth_token] = nil
  end
  
  def generate_signed_cookie_value(value, digest = 'SHA1', serializer = Marshal)
    salt   = Rails.application.config.action_dispatch.signed_cookie_salt
    secret = Rails.application.key_generator.generate_key(salt)
    ActiveSupport::MessageVerifier.new(secret, digest: digest, serializer: serializer).generate(value)
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end