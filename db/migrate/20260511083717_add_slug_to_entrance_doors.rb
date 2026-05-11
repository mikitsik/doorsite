# frozen_string_literal: true

class AddSlugToEntranceDoors < ActiveRecord::Migration[8.1]
  def change
    add_column :entrance_doors, :slug, :string
    add_index :entrance_doors, :slug, unique: true
  end
end
