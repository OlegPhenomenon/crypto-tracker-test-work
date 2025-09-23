class NotificationChannel < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy
  has_many :alerts, through: :alert_notifications

  def send_notification(alert)
    raise NotImplementedError, "#{self.class.name} must implement :send_notification"
  end
end
