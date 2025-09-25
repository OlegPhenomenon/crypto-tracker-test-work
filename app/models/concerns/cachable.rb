module Cachable
  extend ActiveSupport::Concern

  included do
    after_save :sync_to_redis
    after_destroy :remove_from_redis
    
    after_update do
      if threshold_price_changed? || direction_changed?
        remove_from_redis
        sync_to_redis
      end
    end
  end

  def remove_from_redis
    Rails.cache.redis.with do |conn|
      conn.hdel(redis_key, id)
    end

    Rails.logger.info "--- [Alert] Removed from Redis: #{redis_key} ---"
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
end
