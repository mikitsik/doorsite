# frozen_string_literal: true

class CreateInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    create_table :interior_doors do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
