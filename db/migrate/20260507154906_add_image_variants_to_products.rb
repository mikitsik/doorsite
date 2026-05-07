# frozen_string_literal: true

class AddImageVariantsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :image_thumbnail_url, :string
    add_column :products, :image_medium_url, :string
    add_column :products, :image_original_url, :string
  end
end
