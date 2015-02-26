#! /usr/bin/env ruby
# scripts/job_pusher.rb
# bundle exec scripts/job_pusher.rb Worker::KlassUpdates
klass = ARGV[0]
require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost' }
end

Sidekiq::Client.push('class' => klass, 'args' => [])