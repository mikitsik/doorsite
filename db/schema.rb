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

ActiveRecord::Schema[8.1].define(version: 2026_05_04_104357) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "import_batches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "failed_count", default: 0, null: false
    t.datetime "finished_at"
    t.integer "imported_count", default: 0, null: false
    t.bigint "product_source_id", null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_count", default: 0, null: false
    t.index ["product_source_id"], name: "index_import_batches_on_product_source_id"
    t.index ["started_at"], name: "index_import_batches_on_started_at"
    t.index ["status"], name: "index_import_batches_on_status"
  end

  create_table "product_sources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "source_type", null: false
    t.string "sync_strategy", default: "manual", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["enabled"], name: "index_product_sources_on_enabled"
    t.index ["source_type"], name: "index_product_sources_on_source_type"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "brand", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BYN", null: false
    t.text "description"
    t.string "external_id"
    t.string "image_url"
    t.bigint "import_batch_id"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_source_id"
    t.jsonb "raw_data", default: {}, null: false
    t.text "searchable_text"
    t.string "slug", null: false
    t.decimal "source_price", precision: 10, scale: 2
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "vendor_code"
    t.index ["active"], name: "index_products_on_active"
    t.index ["brand"], name: "index_products_on_brand"
    t.index ["category"], name: "index_products_on_category"
    t.index ["external_id", "product_source_id"], name: "index_products_on_external_id_and_source", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["import_batch_id"], name: "index_products_on_import_batch_id"
    t.index ["product_source_id"], name: "index_products_on_product_source_id"
    t.index ["searchable_text"], name: "index_products_on_searchable_text_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["vendor_code"], name: "index_products_on_vendor_code"
  end

  add_foreign_key "import_batches", "product_sources"
  add_foreign_key "products", "import_batches"
  add_foreign_key "products", "product_sources"
end
