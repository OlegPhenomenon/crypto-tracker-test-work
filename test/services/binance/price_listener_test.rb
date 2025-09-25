# test/services/binance/price_listener_test.rb
require "test_helper"

class Listeners::BinancePriceListenerTest < ActiveSupport::TestCase
  setup do
    @listener = Listeners::BinancePriceListener.new
    @redis = @listener.redis
    @redis.flushdb
  end

  test "triggers alert and removes it from redis when price crosses up" do
    symbol = "BTCUSDT"
    redis_key = "alerts:binance:#{symbol}"
    alert_id = 1
    @redis.hset(redis_key, alert_id, "50000_up")

    ticker = { "s" => symbol, "c" => "51000.0" }
    @listener.send(:process_ticker, ticker)

    key_exists = @redis.hexists(redis_key, alert_id)
    refute key_exists, "Alert should be removed from Redis after triggering"
  end

  test "triggers alert and removes it from redis when price crosses down" do
    symbol = "ETHUSDT"
    redis_key = "alerts:binance:#{symbol}"
    alert_id = 2
    @redis.hset(redis_key, alert_id, "4000_down")

    ticker = { "s" => symbol, "c" => "3900.0" }
    @listener.send(:process_ticker, ticker)

    refute @redis.hexists(redis_key, alert_id), "Alert should be removed from Redis"
  end

  test "does not trigger alert if price does not cross threshold" do
    symbol = "BTCUSDT"
    redis_key = "alerts:binance:#{symbol}"
    alert_id = 1
    @redis.hset(redis_key, alert_id, "50000_up")

    ticker = { "s" => symbol, "c" => "49000.0" }
    @listener.send(:process_ticker, ticker)

    assert @redis.hexists(redis_key, alert_id), "Alert should not be removed if not triggered"
  end

  test "does nothing if there are no alerts for the symbol" do
    ticker = { "s" => "XRPUSDT", "c" => "1.5" }

    assert_nothing_raised do
      @listener.send(:process_ticker, ticker)
    end
  end
end
