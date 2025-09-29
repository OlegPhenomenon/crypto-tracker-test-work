class EmailChannel < NotificationChannel
  store_accessor :details, :email
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.permitted_details
    [ :email, :title ]
  end

  def send_notification(alert)
    # AlertMailer.alert_triggered(alert, self).deliver_later
    Rails.logger.info "Email notification sent to #{self.email} for alert #{alert.id}"
  end
end
