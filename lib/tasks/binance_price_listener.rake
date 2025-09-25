namespace :binance_price_listener do
  desc "Starts the Price Listener for Binance"
  task run: :environment do
    puts "Starting Price Listener..."
    Listeners::BinancePriceListener.new.run
  end
end
