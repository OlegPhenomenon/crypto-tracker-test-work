class CreateAlertNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_notifications do |t|
      t.references :alert, null: false, foreign_key: true
      t.references :notification_channel, null: false, foreign_key: true

      t.timestamps
    end

    add_index :alert_notifications, [ :alert_id, :notification_channel_id ], unique: true
  end
end
