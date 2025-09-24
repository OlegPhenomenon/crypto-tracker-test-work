# test/controllers/workspaces_controller_test.rb
require "test_helper"

class WorkspacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alert_attributes = {
      exchange: 'binance',
      symbol: 'BTCUSDT',
      threshold_price: 50000,
      direction: 'up',
      status: 'active'
    }
  end

  test "should get index" do
    get workspaces_url
    assert_response :success
    
    assert_not_nil assigns(:alert)
    assert_not_nil assigns(:alerts)
  end

  test "should create alert with a new notification channel" do
    email_channel = notification_channels(:email_channel)

    assert_difference("Alert.count", 1) do
      post workspaces_url, params: {
        alert: {
          exchange: 'binance',
          symbol: 'ADAUSDT',
          threshold_price: 1.5,
          direction: 'up',
          status: 'active'
        },
        # Send an array of IDs, as the controller expects
        notification_channel_ids: [email_channel.id]
      }
    end


    assert_redirected_to workspaces_url
    assert_equal "Alert was successfully created.", flash[:notice]

    assert_includes Alert.last.notification_channel_ids, email_channel.id
    assert_equal 'original@example.com', Alert.last.notification_channels.first.details['email']
  end

  test "should not create alert with invalid parameters" do
    assert_no_difference "Alert.count" do
      post workspaces_url, params: { alert: @alert_attributes.merge(symbol: ''), notification_channels: { "TelegramChannel" => { selected: '0' } } }
    end

    assert_response :unprocessable_entity
    assert_template :index
  end
end
