class EmailChannel < NotificationChannel
  store_accessor :details, :email
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def send_notification(alert)
    AlertMailer.alert_triggered(alert, self).deliver_later
  end
end
