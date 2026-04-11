class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :brand, null: false
      t.string :category, null: false
      t.decimal :price, precision: 10, scale: 2
      t.string :currency, null: false, default: "BYN"
      t.string :image_url
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :brand
    add_index :products, :category
    add_index :products, :active
  end
end
