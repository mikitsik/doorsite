# frozen_string_literal: true

class RefineInteriorDoorDomainFields < ActiveRecord::Migration[8.1]
  def change
    rename_column :interior_doors, :variant_color, :vendor_color
    add_column :interior_doors, :hint_tone, :string, null: false, default: 'unknown'

    remove_index :interior_doors, :variant_group_key
    remove_column :interior_doors, :variant_group_key, :string

    remove_column :interior_doors, :collection, :string

    add_index :interior_doors, :vendor_color
    add_index :interior_doors, :hint_tone
    add_index :interior_doors, %i[dealer series door_model]
  end
end
