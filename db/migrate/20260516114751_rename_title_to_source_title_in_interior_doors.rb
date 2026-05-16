# frozen_string_literal: true

class RenameTitleToSourceTitleInInteriorDoors < ActiveRecord::Migration[8.1]
  def change
    rename_column :interior_doors, :title, :source_title
  end
end
