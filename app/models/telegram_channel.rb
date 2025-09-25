require 'telegram/bot'

class TelegramChannel < NotificationChannel
  encrypts :token

  store_accessor :details, :chat_id

  validates :chat_id, presence: true, format: { with: /\A-?\d+\z/, message: "must be an integer" }
  validates :bot_token, presence: true, on: :create

  def self.permitted_details
    [:bot_token, :chat_id, :title]
  end

  before_save :set_encrypted_token_from_details
  after_find :set_details_from_encrypted_token

  def bot_token
    @bot_token || details['bot_token']
  end

  def bot_token=(value)
    @bot_token = value if value.present?
  end

  def send_notification(alert)
    message = "🔔 *Crypto Alert Triggered!* 🔔\n\n" \
              "*Symbol:* `#{alert.symbol}`\n" \
              "*Condition:* Price crossed *#{alert.direction}* `#{alert.threshold_price}`"
  
    bot = Telegram::Bot::Client.new(self.bot_token)
    bot.api.send_message(chat_id: self.chat_id, text: message, parse_mode: 'Markdown')

    Rails.logger.info "✅ Telegram notification sent successfully to chat_id: #{self.chat_id} for Alert ##{alert.id}"
  rescue => e
    Rails.logger.error "❌ Failed to send Telegram notification for Alert ##{alert.id}: #{e.message}"
  end

  private

  def set_encrypted_token_from_details
    self.details['bot_token'] = bot_token
  end

  def set_details_from_encrypted_token
    @bot_token = self.details['bot_token']
  end
end
