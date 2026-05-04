# frozen_string_literal: true

class EnablePgTrgmAndAddSearchIndexToProducts < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    add_index :products,
              :searchable_text,
              using: :gin,
              opclass: :gin_trgm_ops,
              name: 'index_products_on_searchable_text_trgm'
  end
end
