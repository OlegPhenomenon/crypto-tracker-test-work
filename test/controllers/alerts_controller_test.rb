require "test_helper"

class AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alert = alerts(:one)
    @alert.notification_channels = [notification_channels(:telegram_channel)]
  end

  test "should get index" do
    get alerts_url
    assert_response :success
  end

  test "should get new" do
    get new_alert_url
    assert_response :success
  end

  test "should create alert" do
    assert_difference("Alert.count") do
      telegram_channel_id = notification_channels(:telegram_channel).id

      post alerts_url, params: {
        alert: {
          direction: @alert.direction,
          exchange: @alert.exchange,
          status: @alert.status,
          symbol: "XRPUSDT",
          threshold_price: @alert.threshold_price,
          notification_channel_ids: [telegram_channel_id] 
        },
      }
    end

    assert_redirected_to alert_url(Alert.last)
    assert_equal "Alert was successfully created.", flash[:notice]
  end

  test "should not create alert with invalid data" do
    assert_no_difference("Alert.count") do
      post alerts_url, params: { alert: { symbol: "" } }
    end

    assert_response :unprocessable_entity
    assert_template :new
  end

  test "should show alert" do
    get alert_url(@alert)
    assert_response :success
  end

  test "should get edit" do
    get edit_alert_url(@alert)
    assert_response :success
  end

  test "should update alert" do
    # Get the ID of a channel from your fixtures
    telegram_channel_id = notification_channels(:telegram_channel).id
    
    patch alert_url(@alert), params: { 
      alert: { symbol: "ADAUSDT" },
      # Send the channel IDs separately, just like a form would
      notification_channel_ids: [telegram_channel_id] 
    }

    assert_redirected_to alert_url(@alert)
    @alert.reload
    assert_equal "ADAUSDT", @alert.symbol
    assert_equal 1, @alert.notification_channels.count
    assert_equal telegram_channel_id, @alert.notification_channels.first.id
  end

  test "should not update alert with invalid data" do
    patch alert_url(@alert), params: { 
      alert: { symbol: "" },
      notification_channel_ids: [notification_channels(:telegram_channel).id]
    }
    
    assert_response :unprocessable_entity
    assert_template :edit
  end

  test "should destroy alert" do
    assert_difference("Alert.count", -1) do
      delete alert_url(@alert)
    end

    assert_redirected_to alerts_url
    assert_equal "Alert was successfully destroyed.", flash[:notice]
  end
end
