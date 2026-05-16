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

ActiveRecord::Schema[8.1].define(version: 2026_05_16_114751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

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
    t.string "slug"
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
    t.index ["slug"], name: "index_entrance_doors_on_slug", unique: true
  end

  create_table "interior_doors", force: :cascade do |t|
    t.string "brand"
    t.datetime "created_at", null: false
    t.string "dealer"
    t.text "description"
    t.string "door_model"
    t.string "external_id"
    t.string "glass"
    t.integer "height_mm"
    t.string "hint_tone", default: "unknown", null: false
    t.text "image_medium_url"
    t.text "image_original_url"
    t.text "image_thumbnail_url"
    t.string "image_url"
    t.string "material"
    t.jsonb "raw_data", default: {}, null: false
    t.text "searchable_text"
    t.string "series"
    t.string "slug", null: false
    t.decimal "source_price", precision: 10, scale: 2
    t.string "source_title", null: false
    t.text "source_url"
    t.integer "thickness_mm"
    t.datetime "updated_at", null: false
    t.string "vendor_color"
    t.integer "width_mm"
    t.index ["brand"], name: "index_interior_doors_on_brand"
    t.index ["dealer", "external_id"], name: "index_interior_doors_on_dealer_and_external_id", unique: true
    t.index ["door_model"], name: "index_interior_doors_on_door_model"
    t.index ["hint_tone"], name: "index_interior_doors_on_hint_tone"
    t.index ["series"], name: "index_interior_doors_on_series"
    t.index ["slug"], name: "index_interior_doors_on_slug", unique: true
    t.index ["vendor_color"], name: "index_interior_doors_on_vendor_color"
  end

  create_table "system_doors", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "brand"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "image_url"
    t.decimal "price", precision: 10, scale: 2
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["brand"], name: "index_system_doors_on_brand"
    t.index ["category"], name: "index_system_doors_on_category"
    t.index ["slug"], name: "index_system_doors_on_slug", unique: true
  end
end
