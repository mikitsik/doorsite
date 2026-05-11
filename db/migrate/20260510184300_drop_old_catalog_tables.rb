# frozen_string_literal: true

class DropOldCatalogTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :products, if_exists: true
    drop_table :import_batches, if_exists: true
    drop_table :catalog_categories, if_exists: true
    drop_table :product_sources, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
