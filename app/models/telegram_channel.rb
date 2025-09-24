require 'telegram/bot'

class TelegramChannel < NotificationChannel
  encrypts :token
  
  store_accessor :details, :chat_id

  validates :chat_id, presence: true, format: { with: /\A-?\d+\z/, message: "must be an integer" }
  validates :bot_token, presence: true

  before_save :set_encrypted_token_from_details
  after_find :set_details_from_encrypted_token

  def bot_token
    @bot_token || details['bot_token']
  end

  def bot_token=(value)
    @bot_token = value
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
    self.token = @bot_token if @bot_token.present?
    self.details['bot_token'] = nil if @bot_token.present?
  end

  def set_details_from_encrypted_token
    @bot_token = self.token
  end
end
