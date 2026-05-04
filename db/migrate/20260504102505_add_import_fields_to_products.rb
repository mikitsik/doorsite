# frozen_string_literal: true

class AddImportFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :source_price, :decimal, precision: 10, scale: 2
    add_column :products, :source_url, :string
    add_column :products, :external_id, :string
    add_column :products, :vendor_code, :string
    add_column :products, :raw_data, :jsonb, default: {}, null: false
    add_column :products, :searchable_text, :text

    add_reference :products, :product_source, foreign_key: true
    add_reference :products, :import_batch, foreign_key: true

    add_index :products, %i[external_id product_source_id],
              unique: true,
              where: 'external_id IS NOT NULL',
              name: 'index_products_on_external_id_and_source'

    add_index :products, :vendor_code
  end
end
