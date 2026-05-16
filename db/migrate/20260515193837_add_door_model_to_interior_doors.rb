# frozen_string_literal: true

class AddDoorModelToInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    add_column :interior_doors, :door_model, :string
    add_index :interior_doors, :door_model
  end
end
