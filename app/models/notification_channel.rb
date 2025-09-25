class NotificationChannel < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy
  has_many :alerts, through: :alert_notifications
  validates :title, presence: true
  
  def send_notification(alert)
    raise NotImplementedError, "#{self.class.name} must implement :send_notification"
  end
end
