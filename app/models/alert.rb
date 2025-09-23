class Alert < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy
  has_many :notification_channels, through: :alert_notifications

  SYMBOLS = %w[BTCUSDT ETHUSDT PYTHUSDT ADAUSDT BNBUSDT SOLUSDT XRPUSDT DOTUSDT LINKUSDT].freeze

  validates :symbol, presence: true, inclusion: { in: SYMBOLS }
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
  validates :direction, presence: true, inclusion: { in: %w[up down] }
  validates :status, presence: true, inclusion: { in: %w[active triggered] }

  after_save :sync_to_redis
  after_destroy :remove_from_redis

  enum :direction, { up: 'up', down: 'down' }
  enum :exchange, { binance: 'binance' }
  enum :status, { active: 'active', triggered: 'triggered' }

  def self.symbols
    SYMBOLS
  end

  private

  def redis_key
    "alerts:#{exchange}:#{symbol}"
  end
  
  def sync_to_redis
    return unless status == 'active'
  
    redis_field = id
    redis_value = "#{threshold_price.to_f}_#{direction}"
  
    Rails.cache.redis.with do |conn|
      conn.hset(redis_key, redis_field, redis_value)
    end
  end
  
  def remove_from_redis
    Rails.cache.redis.with do |conn|
      conn.hdel(redis_key, id)
    end
  end
end
