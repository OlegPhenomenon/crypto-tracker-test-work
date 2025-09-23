namespace :price_broadcaster do
  desc "Starts the Price Broadcaster Job"
  task run: :environment do
    puts "Starting Price Broadcaster..."
    PriceBroadcasterJob.perform_now
  end
end
