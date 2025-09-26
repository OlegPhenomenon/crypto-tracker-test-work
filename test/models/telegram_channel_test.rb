require "test_helper"
require "minitest/mock"

class TelegramChannelTest < ActiveSupport::TestCase
  setup do
    @channel_attributes = {
      title: "Test Telegram Channel",
      chat_id: "-123456789",
      bot_token: "super_secret_token_123"
    }
    @alert = alerts(:one)
  end

  test "should be valid with correct attributes" do
    channel = TelegramChannel.new(@channel_attributes)
    assert channel.valid?
  end

  test "should be invalid without a chat_id" do
    channel = TelegramChannel.new(@channel_attributes.except(:chat_id))
    refute channel.valid?
    assert_not_nil channel.errors[:chat_id]
  end

  test "should be invalid without a bot_token" do
    channel = TelegramChannel.new(@channel_attributes.except(:bot_token))
    refute channel.valid?
    assert_not_nil channel.errors[:bot_token]
  end

  test "send_notification calls Telegram API with correct decrypted token" do
    channel = TelegramChannel.create!(
      title: "Test Telegram Channel",
      chat_id: "-123456789",
      bot_token: "super_secret_token_123"
    )

    expected_message = "🔔 *Crypto Alert Triggered!* 🔔\n\n" \
                       "*Symbol:* `#{@alert.symbol}`\n" \
                       "*Condition:* Price crossed *#{@alert.direction}* `#{@alert.threshold_price}`"

    mock_api = Minitest::Mock.new
    mock_api.expect(:send_message, true, chat_id: channel.chat_id, text: expected_message, parse_mode: "Markdown")

    mock_bot_instance = Minitest::Mock.new
    mock_bot_instance.expect(:api, mock_api)

    Telegram::Bot::Client.stub(:new, mock_bot_instance) do
      channel.send_notification(@alert)
    end

    mock_api.verify
    mock_bot_instance.verify
  end
end
