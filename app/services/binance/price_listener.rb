require "faye/websocket"
require "eventmachine"
require "json"
require "redis"
# require 'sidekiq'
module Binance
  class PriceListener
    WEBSOCKET_URL = "wss://stream.binance.com:9443/ws/!ticker@arr"

    attr_reader :redis

    def initialize
      @redis = Redis.new(url: ENV["REDIS_URL"])
    end

    def run
      EM.run do
        ws = Faye::WebSocket::Client.new(WEBSOCKET_URL)

        ws.on :open do |event|
          p [ :open, "Connected to Binance WebSocket" ]
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)
          data.each { |ticker| process_ticker(ticker) }
        end

        ws.on :close do |event|
          p [ :close, event.code, event.reason ]
          ws = nil
        end
      end
    end

    private

    def process_ticker(ticker)
      symbol = ticker["s"]
      price = BigDecimal(ticker["c"])
      redis_key = "alerts:binance:#{symbol}"
      alerts_to_check = @redis.hgetall(redis_key)

      return if alerts_to_check.empty?

      alerts_to_check.each do |alert_id, condition|
        threshold_str, direction = condition.split("_")
        threshold = BigDecimal(threshold_str)

        price_crossed_up = (direction == "up" && price > threshold)
        price_crossed_down = (direction == "down" && price < threshold)

        if price_crossed_up || price_crossed_down
          puts "!!! ALERT TRIGGERED: #{symbol} price #{price} crossed #{direction} #{threshold} (Alert ID: #{alert_id})"

          # Sidekiq::Client.push(
          #   'queue' => 'default',
          #   'class' => 'NotificationJob',
          #   'args' => [alert_id.to_i]
          # )

          @redis.hdel(redis_key, alert_id)
        end
      end
    end
  end
end
