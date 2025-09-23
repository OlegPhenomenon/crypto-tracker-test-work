class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.string :symbol, null: false
      t.decimal :threshold_price, null: false, precision: 16, scale: 8
      t.string :direction, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :alerts, :symbol
  end
end
