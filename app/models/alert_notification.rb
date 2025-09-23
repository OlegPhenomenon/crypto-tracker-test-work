class AlertNotification < ApplicationRecord
  belongs_to :alert
  belongs_to :notification_channel
end
