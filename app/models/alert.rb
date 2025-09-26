class Alert < ApplicationRecord
  include Symbols
  include Cachable

  has_many :alert_notifications, dependent: :destroy
  has_many :notification_channels, through: :alert_notifications

  validates :symbol, inclusion: {
    in: ->(alert) { Alert.symbols(provider: alert&.exchange&.to_sym) },
    message: "%{value} is not a valid symbol for the selected exchange"
  }
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
  validates :direction, presence: true
  validates :status, presence: true
  validates :exchange, presence: true
  validate :must_have_notification_channels

  DIRECTIONS = { up: "up", down: "down" }

  enum :direction, DIRECTIONS
  enum :exchange, { binance: "binance" }
  enum :status, { active: "active", triggered: "triggered" }

  private

  def must_have_notification_channels
    if notification_channels.empty?
      errors.add(:notification_channels, "must have at least one notification channel")
    end
  end
end
