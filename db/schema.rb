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

ActiveRecord::Schema[8.1].define(version: 2026_05_09_130713) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "catalog_categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.string "kind", null: false
    t.bigint "parent_id"
    t.jsonb "path", default: [], null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "source", null: false
    t.string "source_category_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_catalog_categories_on_kind"
    t.index ["parent_id"], name: "index_catalog_categories_on_parent_id"
    t.index ["path"], name: "index_catalog_categories_on_path", using: :gin
    t.index ["position"], name: "index_catalog_categories_on_position"
    t.index ["slug"], name: "index_catalog_categories_on_slug", unique: true
    t.index ["source", "source_category_id"], name: "index_catalog_categories_on_source_and_source_category_id", unique: true
    t.index ["source"], name: "index_catalog_categories_on_source"
    t.index ["source_category_id"], name: "index_catalog_categories_on_source_category_id"
  end

  create_table "entrance_doors", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.boolean "available", default: true, null: false
    t.string "brand"
    t.string "category"
    t.string "collection"
    t.string "construction_type"
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "dealer"
    t.text "description"
    t.string "external_id"
    t.string "filling"
    t.string "glass"
    t.integer "height_mm"
    t.string "image_url"
    t.string "inner_color"
    t.string "inner_finish"
    t.integer "locks_count"
    t.string "material"
    t.decimal "metal_thickness_mm", precision: 5, scale: 2
    t.decimal "old_price", precision: 10, scale: 2
    t.string "opening_direction"
    t.string "opening_side"
    t.string "outer_color"
    t.string "outer_finish"
    t.decimal "price", precision: 10, scale: 2
    t.jsonb "raw_data", default: {}, null: false
    t.integer "sealing_contours_count"
    t.text "searchable_text"
    t.string "series"
    t.decimal "source_price", precision: 10, scale: 2
    t.string "source_url"
    t.boolean "thermal_break", default: false, null: false
    t.integer "thickness_mm"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "use_case"
    t.integer "warranty_months"
    t.integer "width_mm"
    t.index ["active"], name: "index_entrance_doors_on_active"
    t.index ["available"], name: "index_entrance_doors_on_available"
    t.index ["brand"], name: "index_entrance_doors_on_brand"
    t.index ["category"], name: "index_entrance_doors_on_category"
    t.index ["dealer", "external_id"], name: "index_entrance_doors_on_dealer_and_external_id", unique: true
    t.index ["series"], name: "index_entrance_doors_on_series"
  end

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
    t.boolean "available", default: true, null: false
    t.string "brand", null: false
    t.bigint "catalog_category_id"
    t.string "catalog_section"
    t.string "category", null: false
    t.string "collection"
    t.string "color"
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.string "currency", default: "BYN", null: false
    t.string "dealer"
    t.text "description"
    t.decimal "discount", precision: 5, scale: 2
    t.string "door_type"
    t.string "external_id"
    t.string "finish"
    t.string "glass"
    t.string "image_medium_url"
    t.string "image_original_url"
    t.string "image_thumbnail_url"
    t.string "image_url"
    t.bigint "import_batch_id"
    t.string "material"
    t.decimal "old_price", precision: 10, scale: 2
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_source_id"
    t.jsonb "raw_data", default: {}, null: false
    t.text "searchable_text"
    t.string "slug", null: false
    t.string "source_category"
    t.string "source_category_id"
    t.jsonb "source_category_path", default: [], null: false
    t.string "source_category_title"
    t.decimal "source_price", precision: 10, scale: 2
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "vendor_code"
    t.index ["active"], name: "index_products_on_active"
    t.index ["brand"], name: "index_products_on_brand"
    t.index ["catalog_category_id"], name: "index_products_on_catalog_category_id"
    t.index ["catalog_section"], name: "index_products_on_catalog_section"
    t.index ["category"], name: "index_products_on_category"
    t.index ["dealer"], name: "index_products_on_dealer"
    t.index ["door_type"], name: "index_products_on_door_type"
    t.index ["external_id", "product_source_id"], name: "index_products_on_external_id_and_source", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["import_batch_id"], name: "index_products_on_import_batch_id"
    t.index ["product_source_id"], name: "index_products_on_product_source_id"
    t.index ["searchable_text"], name: "index_products_on_searchable_text_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["source_category_id"], name: "index_products_on_source_category_id"
    t.index ["source_category_path"], name: "index_products_on_source_category_path", using: :gin
    t.index ["vendor_code"], name: "index_products_on_vendor_code"
  end

  add_foreign_key "catalog_categories", "catalog_categories", column: "parent_id"
  add_foreign_key "import_batches", "product_sources"
  add_foreign_key "products", "catalog_categories"
  add_foreign_key "products", "import_batches"
  add_foreign_key "products", "product_sources"
end
