require 'faye/websocket'
require 'eventmachine'
require 'json'

module Binance
  class PriceListener
    # WebSocket URL for all tickers
    WEBSOCKET_URL = "wss://stream.binance.com:9443/ws/!ticker@arr"

    def run
      EM.run do
        ws = Faye::WebSocket::Client.new(WEBSOCKET_URL)

        ws.on :open do |event|
          p [:open, "Connected to Binance WebSocket"]
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)
          data.each do |ticker|
            process_ticker(ticker)
          end
        end

        ws.on :close do |event|
          p [:close, event.code, event.reason]
          ws = nil
        end
      end
    end

    private

    def process_ticker(ticker)
      symbol = ticker['s']
      price = ticker['c']
      
      puts "Symbol: #{symbol}, Price: #{price}"
      
      # TODO: check alerts in Redis
    end
  end
end
