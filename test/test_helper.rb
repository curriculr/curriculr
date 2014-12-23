ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Devise test helpers
  #include Devise::TestHelpers
end

class ActionController::TestCase
	# Devise test helpers
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  
  # Devise test helpers
  include Warden::Test::Helpers
  Warden.test_mode!
end