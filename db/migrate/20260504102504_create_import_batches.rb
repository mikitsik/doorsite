class CreateImportBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :import_batches do |t|
      t.references :product_source, null: false, foreign_key: true

      t.string :status, null: false, default: "pending"
      t.integer :imported_count, null: false, default: 0
      t.integer :updated_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.text :error_message
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :import_batches, :status
    add_index :import_batches, :started_at
  end
end
