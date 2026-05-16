# frozen_string_literal: true

class SimplifyInteriorDoorsFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :interior_doors, :active, :boolean, default: true, null: false
    remove_column :interior_doors, :available, :boolean, default: true, null: false
    remove_column :interior_doors, :currency, :string
    remove_column :interior_doors, :finish, :string
    remove_column :interior_doors, :old_price, :decimal, precision: 10, scale: 2
    remove_column :interior_doors, :price, :decimal, precision: 10, scale: 2

    remove_index :interior_doors,
                 column: %i[dealer series door_model],
                 name: 'index_interior_doors_on_dealer_and_series_and_door_model'
  end
end
