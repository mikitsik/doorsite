# frozen_string_literal: true

class AddFieldsToInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    change_table :interior_doors, bulk: true do |t|
      t.string :dealer
      t.string :external_id

      t.string :series
      t.string :collection

      t.string :variant_group_key
      t.string :variant_name
      t.string :variant_color

      t.string :material
      t.string :finish
      t.string :glass

      t.integer :height_mm
      t.integer :width_mm
      t.integer :thickness_mm

      t.decimal :source_price, precision: 10, scale: 2
      t.decimal :old_price, precision: 10, scale: 2

      t.text :image_thumbnail_url
      t.text :image_medium_url
      t.text :image_original_url

      t.text :source_url
      t.text :description

      t.boolean :available, default: true, null: false

      t.jsonb :raw_data, default: {}, null: false

      t.text :searchable_text
    end

    add_index :interior_doors, %i[dealer external_id], unique: true

    add_index :interior_doors, :variant_group_key
    add_index :interior_doors, :series
  end
end
