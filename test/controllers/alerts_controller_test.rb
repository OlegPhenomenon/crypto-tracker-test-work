require "test_helper"

class AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alert = alerts(:one)
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
      post alerts_url, params: {
        alert: {
          direction: @alert.direction,
          exchange: @alert.exchange,
          status: @alert.status,
          symbol: "XRPUSDT",
          threshold_price: @alert.threshold_price
        }
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
    patch alert_url(@alert), params: { alert: { symbol: "ADAUSDT" } }

    assert_redirected_to alert_url(@alert)
    
    @alert.reload
    assert_equal "ADAUSDT", @alert.symbol
    assert_equal "Alert was successfully updated.", flash[:notice]
  end

  test "should not update alert with invalid data" do
    patch alert_url(@alert), params: { alert: { symbol: "" } }
    
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