# frozen_string_literal: true

class RemoveVariantNameFromInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    remove_column :interior_doors, :variant_name, :string
  end
end
