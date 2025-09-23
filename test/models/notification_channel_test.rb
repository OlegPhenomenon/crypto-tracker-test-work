require "test_helper"

class NotificationChannelTest < ActiveSupport::TestCase
  test "should raise NotImplementedError" do
    channel = NotificationChannel.new
    alert = Alert.new(id: 1)

    assert_raises NotImplementedError do
      channel.send_notification(alert)
    end
  end
end
