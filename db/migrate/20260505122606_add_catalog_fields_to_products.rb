# frozen_string_literal: true

class AddCatalogFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :door_type, :string
    add_column :products, :dealer, :string
    add_column :products, :collection, :string

    add_column :products, :old_price, :decimal, precision: 10, scale: 2
    add_column :products, :discount, :decimal, precision: 5, scale: 2

    add_column :products, :color, :string
    add_column :products, :material, :string
    add_column :products, :finish, :string
    add_column :products, :glass, :string

    add_column :products, :country_of_origin, :string

    add_column :products, :source_category, :string
    add_column :products, :source_category_id, :string

    add_column :products, :available, :boolean, default: true, null: false

    add_index :products, :door_type
    add_index :products, :dealer
    add_index :products, :source_category_id
  end
end
