
namespace :price_listener do
  desc "Starts the Price Listener for Binance"
  task run: :environment do
    puts "Starting Price Listener..."
    Binance::PriceListener.new.run
  end
end
