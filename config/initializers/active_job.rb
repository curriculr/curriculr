if Rails.env.production? 
  KlassUpdatesJob.set(wait: 2.minutes).perform_later(true)
end