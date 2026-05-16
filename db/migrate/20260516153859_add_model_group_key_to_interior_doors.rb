# frozen_string_literal: true

class AddModelGroupKeyToInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    add_column :interior_doors, :model_group_key, :string
    add_index :interior_doors, :model_group_key
  end
end
