class LogChannel < NotificationChannel
  def self.permitted_details
    [ :title ]
  end

  def send_notification(alert)
    Rails.logger.info "✅ LOG NOTIFICATION: Alert ##{alert.id} for #{alert.symbol} triggered at price #{alert.threshold_price}."
  end
end
