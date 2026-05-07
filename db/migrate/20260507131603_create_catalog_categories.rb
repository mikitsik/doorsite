# frozen_string_literal: true

class CreateCatalogCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_categories do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :kind, null: false
      t.references :parent, null: true, foreign_key: { to_table: :catalog_categories }
      t.string :source, null: false
      t.string :source_category_id
      t.integer :position, default: 0, null: false
      t.integer :depth, default: 0, null: false
      t.jsonb :path, default: [], null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :catalog_categories, :slug, unique: true
    add_index :catalog_categories, :kind
    add_index :catalog_categories, :source
    add_index :catalog_categories, :source_category_id
    add_index :catalog_categories, :position
    add_index :catalog_categories, :path, using: :gin
    add_index :catalog_categories, %i[source source_category_id], unique: true
  end
end
