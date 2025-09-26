require "faye/websocket"
require "eventmachine"
require "json"
require "redis"
require "sidekiq"

module Listeners
  class BinancePriceListener < ListenerInterface
    WEBSOCKET_URL = "wss://stream.binance.com:9443/ws/!ticker@arr"

    attr_reader :redis

    def initialize
      @redis = Redis.new(url: ENV["REDIS_URL"])
    end

    def run
      puts "Starting Binance price listener..."
      loop do
        EM.run do
          connect_and_listen
        end

        puts "WebSocket connection closed. Reconnecting in 5 seconds..."
        sleep 5
      end
    end

    private

    def connect_and_listen
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
        EM.stop
      end
    end

    def process_ticker(ticker)
      symbol = ticker["s"]
      price = BigDecimal(ticker["c"])
      redis_key = "alerts:binance:#{symbol}"
      alerts_to_check = @redis.hgetall(redis_key)

      return unless Alert.symbols(provider: :binance).include?(symbol)

      ActionCable.server.broadcast("prices_for_#{symbol}", { price: price })

      return if alerts_to_check.empty?

      alerts_to_check.each do |alert_id, condition|
        threshold_str, direction = condition.split("_")
        threshold = BigDecimal(threshold_str)

        price_crossed_up = (direction == "up" && price > threshold)
        price_crossed_down = (direction == "down" && price < threshold)

        if price_crossed_up || price_crossed_down
          NotificationJob.perform_later(alert_id.to_i)

          @redis.hdel(redis_key, alert_id)
        end
      end
    end
  end
end
