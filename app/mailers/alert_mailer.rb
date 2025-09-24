class AlertMailer < ApplicationMailer
  def alert_triggered(alert, email_channel)
    @alert = alert

    mail(to: email_channel.email, subject: "Crypto Alert Triggered for #{@alert.symbol}!")
  end
end
