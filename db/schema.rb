# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_24_085446) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alert_notifications", force: :cascade do |t|
    t.bigint "alert_id", null: false
    t.bigint "notification_channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id", "notification_channel_id"], name: "idx_on_alert_id_notification_channel_id_f6336bd1ae", unique: true
    t.index ["alert_id"], name: "index_alert_notifications_on_alert_id"
    t.index ["notification_channel_id"], name: "index_alert_notifications_on_notification_channel_id"
  end

  create_table "alerts", force: :cascade do |t|
    t.string "symbol", null: false
    t.decimal "threshold_price", precision: 16, scale: 8, null: false
    t.string "direction", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "exchange", null: false
    t.index ["exchange"], name: "index_alerts_on_exchange"
    t.index ["symbol"], name: "index_alerts_on_symbol"
  end

  create_table "notification_channels", force: :cascade do |t|
    t.string "type", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", default: "N/A", null: false
  end

  add_foreign_key "alert_notifications", "alerts"
  add_foreign_key "alert_notifications", "notification_channels"
end
