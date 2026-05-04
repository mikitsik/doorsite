# frozen_string_literal: true

class CreateProductSources < ActiveRecord::Migration[8.1]
  def change
    create_table :product_sources do |t|
      t.string :name, null: false
      t.string :source_type, null: false
      t.string :url
      t.boolean :enabled, null: false, default: true
      t.string :sync_strategy, null: false, default: 'manual'
      t.jsonb :settings, null: false, default: {}
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :product_sources, :source_type
    add_index :product_sources, :enabled
  end
end
