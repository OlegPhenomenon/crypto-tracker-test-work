class AddExchangeToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :exchange, :string, null: false
    add_index :alerts, :exchange
  end
end
