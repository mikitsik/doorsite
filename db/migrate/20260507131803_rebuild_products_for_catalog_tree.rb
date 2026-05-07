# frozen_string_literal: true

class RebuildProductsForCatalogTree < ActiveRecord::Migration[8.1]
  def change
    add_reference :products, :catalog_category, foreign_key: true

    add_column :products, :catalog_section, :string
    add_column :products, :source_category_title, :string
    add_column :products, :source_category_path, :jsonb, default: [], null: false

    add_index :products, :catalog_section
    add_index :products, :source_category_path, using: :gin
  end
end
