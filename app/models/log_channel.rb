class LogChannel < NotificationChannel
  def send_notification(alert)
    Rails.logger.info "✅ LOG NOTIFICATION: Alert ##{alert.id} for #{alert.symbol} triggered at price #{alert.threshold_price}."
  end
end
