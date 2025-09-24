require "test_helper"
require "minitest/mock" 

class AlertTest < ActiveSupport::TestCase
  setup do
    @alert = alerts(:one)
    @redis = Rails.cache.redis
    @redis.with { |conn| conn.flushdb }
  end

  test "should be valid with correct attributes" do
    assert @alert.valid?
  end

  test "should be invalid without symbol" do
    @alert.symbol = nil
    refute @alert.valid?, "Alert is valid without symbol"
  end

  test "should raise error for invalid direction" do
    assert_raises(ArgumentError) do
      @alert.direction = 'sideways'
    end
  end

  test "should raise error for invalid exchange" do
    assert_raises(ArgumentError) do
      @alert.exchange = 'bybit'
    end
  end

  test "should add active alert to Redis after saving" do
    alert = Alert.create!(
      exchange: "binance",
      symbol: "BTCUSDT",
      threshold_price: 50000.0,
      direction: "up",
      status: "active",
      notification_channels: [notification_channels(:telegram_channel)]
    )
      
    redis_key = "alerts:binance:BTCUSDT"
    expected_value = "50000.0_up"
    
    actual_value = @redis.with { |conn| conn.hget(redis_key, alert.id) }
    
    assert_equal expected_value, actual_value
  end

  test "should delete alert from Redis after deletion" do
    alert = Alert.create!(
      exchange: "binance",
      symbol: "ETHUSDT",
      threshold_price: 4000.0,
      direction: "down",
      status: "active",
      notification_channels: [notification_channels(:telegram_channel)]
    )
    
    assert @redis.with { |conn| conn.hexists("alerts:binance:ETHUSDT", alert.id) }
    
    alert.destroy
    
    key_exists = @redis.with { |conn| conn.hexists("alerts:binance:ETHUSDT", alert.id) }
    
    refute key_exists, "Key for deleted alert still exists in Redis"
  end
end
