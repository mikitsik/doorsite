# frozen_string_literal: true

class RemoveCategoryFromInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    remove_column :interior_doors, :category, :string
  end
end
