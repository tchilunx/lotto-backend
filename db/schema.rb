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

ActiveRecord::Schema[8.1].define(version: 2025_11_20_193955) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "client_operations", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.decimal "balance_after", precision: 12, scale: 2, null: false
    t.decimal "balance_before", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.bigint "client_wallet_id", null: false
    t.datetime "created_at", null: false
    t.integer "operation_type", null: false
    t.string "reference", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_operations_on_client_id"
    t.index ["client_wallet_id"], name: "index_client_operations_on_client_wallet_id"
  end

  create_table "client_topup_drafts", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "draft_data", default: {}
    t.string "payment_method", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_topup_drafts_on_client_id"
  end

  create_table "client_topups", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "external_reference"
    t.string "payment_method", null: false
    t.string "reference", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_topups_on_client_id"
    t.index ["reference"], name: "index_client_topups_on_reference", unique: true
  end

  create_table "client_wallets", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.boolean "locked"
    t.decimal "real_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "theoretical_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "wallet_type", default: 0
    t.index ["client_id"], name: "index_client_wallets_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "jti", null: false
    t.boolean "kyc_valid", default: false
    t.string "last_name"
    t.string "phone", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_clients_on_jti", unique: true
    t.index ["phone"], name: "index_clients_on_phone", unique: true
  end

  create_table "kyc_requests", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "document_number", null: false
    t.string "document_type", null: false
    t.string "rejection_reason"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_kyc_requests_on_client_id"
  end

  create_table "lotto_bets", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, default: "100.0", null: false
    t.string "bet_reference", null: false
    t.bigint "client_id", null: false
    t.bigint "client_wallet_id", null: false
    t.datetime "created_at", null: false
    t.date "draw_date", null: false
    t.bigint "lotto_draw_id"
    t.integer "numbers", default: [], array: true
    t.integer "session", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["bet_reference"], name: "index_lotto_bets_on_bet_reference", unique: true
    t.index ["client_id", "draw_date", "session"], name: "index_lotto_bets_on_client_id_and_draw_date_and_session"
    t.index ["client_id"], name: "index_lotto_bets_on_client_id"
    t.index ["client_wallet_id"], name: "index_lotto_bets_on_client_wallet_id"
    t.index ["lotto_draw_id"], name: "index_lotto_bets_on_lotto_draw_id"
  end

  create_table "lotto_draws", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "draw_date", null: false
    t.datetime "drawn_at"
    t.integer "numbers", default: [], array: true
    t.integer "session", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["draw_date", "session"], name: "index_lotto_draws_on_draw_date_and_session", unique: true
  end

  create_table "lotto_wins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "credited_at"
    t.bigint "lotto_bet_id", null: false
    t.bigint "lotto_draw_id", null: false
    t.integer "matched_numbers", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "win_amount", precision: 12, scale: 2, null: false
    t.index ["lotto_bet_id"], name: "index_lotto_wins_on_lotto_bet_id"
    t.index ["lotto_draw_id"], name: "index_lotto_wins_on_lotto_draw_id"
  end

  create_table "service_imoney_drafts", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "draft_data", default: {}
    t.string "phone_number", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_service_imoney_drafts_on_client_id"
  end

  create_table "service_imoneys", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "external_reference"
    t.string "phone_number", null: false
    t.string "reference", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_service_imoneys_on_client_id"
    t.index ["reference"], name: "index_service_imoneys_on_reference", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "client_operations", "client_wallets"
  add_foreign_key "client_operations", "clients"
  add_foreign_key "client_topup_drafts", "clients"
  add_foreign_key "client_topups", "clients"
  add_foreign_key "client_wallets", "clients"
  add_foreign_key "kyc_requests", "clients"
  add_foreign_key "lotto_bets", "client_wallets"
  add_foreign_key "lotto_bets", "clients"
  add_foreign_key "lotto_bets", "lotto_draws"
  add_foreign_key "lotto_wins", "lotto_bets"
  add_foreign_key "lotto_wins", "lotto_draws"
  add_foreign_key "service_imoney_drafts", "clients"
  add_foreign_key "service_imoneys", "clients"
end
