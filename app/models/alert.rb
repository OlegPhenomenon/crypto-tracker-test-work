class Alert < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy
  has_many :notification_channels, through: :alert_notifications

  validates :symbol, presence: true
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
  validates :direction, presence: true
  validates :status, presence: true
  validates :exchange, presence: true
  validate :must_have_notification_channels

  after_save :sync_to_redis
  after_destroy :remove_from_redis

  enum :direction, { up: 'up', down: 'down' }
  enum :exchange, { binance: 'binance' }
  enum :status, { active: 'active', triggered: 'triggered' }

  def self.symbols(provider: :binance)
    case provider
    when :binance
      Coins::BinanceCoinFetcher.new.fetch_coins
    else
      raise "Invalid provider: #{provider}"
    end
  end

  def remove_from_redis
    Rails.cache.redis.with do |conn|
      conn.hdel(redis_key, id)
    end

    Rails.logger.info "--- [Alert] Removed from Redis: #{redis_key} ---"
  end

  private

  def must_have_notification_channels
    if notification_channels.empty?
      errors.add(:notification_channels, "must have at least one notification channel")
    end
  end

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
end
