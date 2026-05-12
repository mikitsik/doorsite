# frozen_string_literal: true

class AddCatalogFieldsToInteriorDoorsAndSystemDoors < ActiveRecord::Migration[8.1]
  def change
    change_table :interior_doors do |t|
      t.string :image_url
      t.string :brand, index: true
      t.string :category, index: true
      t.decimal :price, precision: 10, scale: 2
      t.string :currency
    end

    change_table :system_doors do |t|
      t.string :image_url
      t.string :brand, index: true
      t.string :category, index: true
      t.decimal :price, precision: 10, scale: 2
      t.string :currency
    end
  end
end
