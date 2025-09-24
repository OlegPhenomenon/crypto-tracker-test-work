class NotificationJob < ApplicationJob
  queue_as :default

  def perform(alert_id)
    alert = Alert.find_by(id: alert_id)

    unless alert
      logger.warn "--- [NotificationJob] Alert with ID: #{alert_id} not found. Already processed?"
      return
    end

    logger.info "--- [NotificationJob] Processing alert ##{alert.id} for #{alert.symbol}..."

    alert.notification_channels.each do |channel|
      channel.send_notification(alert)
    end

    alert.triggered!

    logger.info "--- [NotificationJob] Finished for Alert ID: #{alert.id} ---"
  end
end