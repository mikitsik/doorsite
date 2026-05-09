# frozen_string_literal: true

class CreateEntranceDoors < ActiveRecord::Migration[8.1]
  def change
    create_table :entrance_doors do |t|
      t.string :dealer
      t.string :external_id
      t.string :title
      t.string :brand
      t.string :series
      t.string :collection
      t.string :category
      t.string :use_case
      t.string :construction_type
      t.boolean :thermal_break, default: false, null: false
      t.string :outer_finish
      t.string :inner_finish
      t.string :outer_color
      t.string :inner_color
      t.string :material
      t.string :filling
      t.string :glass
      t.integer :height_mm
      t.integer :width_mm
      t.integer :thickness_mm
      t.decimal :metal_thickness_mm, precision: 5, scale: 2
      t.string :opening_side
      t.string :opening_direction
      t.integer :locks_count
      t.integer :sealing_contours_count
      t.string :country_of_origin
      t.integer :warranty_months
      t.decimal :price, precision: 10, scale: 2
      t.decimal :source_price, precision: 10, scale: 2
      t.decimal :old_price, precision: 10, scale: 2
      t.string :currency
      t.string :image_url
      t.string :source_url
      t.text :description
      t.boolean :available, default: true, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :raw_data, default: {}, null: false
      t.text :searchable_text

      t.timestamps

      t.index %i[dealer external_id], unique: true
      t.index :brand
      t.index :series
      t.index :category
      t.index :available
      t.index :active
    end
  end
end
