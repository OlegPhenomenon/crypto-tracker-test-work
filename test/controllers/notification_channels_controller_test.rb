require "test_helper"

class NotificationChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email_channel = notification_channels(:email_channel)
    @valid_attributes = {
      type: "TelegramChannel",
      details: {
        bot_token: "test_token_123",
        chat_id: "456"
      }
    }
  end

  test "should get index" do
    get notification_channels_url
    assert_response :success
  end

  test "should get new" do
    get new_notification_channel_url
    assert_response :success
  end

  test "should create notification channel" do
    assert_difference("TelegramChannel.count", 1) do
      post notification_channels_url, params: { notification_channel: { type: "TelegramChannel" }, "telegram_channel" => @valid_attributes }
    end

    assert_redirected_to notification_channel_url(NotificationChannel.last)
    assert_equal "Notification channel was successfully created.", flash[:notice]
    assert_equal "test_token_123", NotificationChannel.last.details["bot_token"]
  end

  test "should show notification channel" do
    get notification_channel_url(@email_channel)
    assert_response :success
  end

  test "should get edit" do
    get edit_notification_channel_url(@email_channel)
    assert_response :success
  end

  test "should update notification channel" do
    patch notification_channel_url(@email_channel), params: {
      email_channel: {
        details: { email: "updated@example.com" }
      }
    }
    assert_redirected_to notification_channel_url(@email_channel)
    @email_channel.reload
    assert_equal "updated@example.com", @email_channel.details["email"]
  end

  test "should destroy notification channel" do
    assert_difference("NotificationChannel.count", -1) do
      delete notification_channel_url(@email_channel)
    end

    assert_redirected_to notification_channels_url
  end

  test "should get form_fields for a channel type" do
    get form_fields_notification_channels_url, params: { channel_type: "TelegramChannel" }, as: :turbo_stream
    assert_response :success
  end
end
