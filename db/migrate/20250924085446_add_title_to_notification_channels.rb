class AddTitleToNotificationChannels < ActiveRecord::Migration[8.0]
  def change
    add_column :notification_channels, :title, :string, null: false, default: 'N/A'
  end
end
