class CreateNotificationChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_channels do |t|
      t.string :type, null: false
      t.jsonb :details, null: false, default: {}

      t.timestamps
    end
  end
end
