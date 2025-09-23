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
    assert_difference ["Alert.count", "EmailChannel.count"], 1 do
      post workspaces_url, params: {
        alert: @alert_attributes,
        notification_channels: {
          
          "EmailChannel" => {
            selected: '1',
            details: { email_address: 'test@example.com' }
          },
          
          "LogChannel" => {
            selected: '0'
          }
        }
      }
    end

    assert_redirected_to workspaces_url
    assert_equal "Alert was successfully created.", flash[:notice]

    assert_equal 1, Alert.last.notification_channels.count
    assert_equal 'test@example.com', Alert.last.notification_channels.first.details['email_address']
  end

  test "should not create alert with invalid parameters" do
    assert_no_difference "Alert.count" do
      post workspaces_url, params: { alert: @alert_attributes.merge(symbol: '') }
    end

    assert_response :unprocessable_entity
    assert_template :index
  end
end