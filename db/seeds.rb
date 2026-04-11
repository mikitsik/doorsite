require "csv"

Product.delete_all

csv_path = Rails.root.join("db/products.csv")

CSV.foreach(csv_path, headers: true) do |row|
  Product.create!(
    slug: row["slug"],
    title: row["title"],
    brand: row["brand"],
    category: row["category"],
    price: row["price"],
    currency: row["currency"],
    image_url: row["image_url"],
    description: row["description"],
    active: row["active"] == "true"
  )
end

puts "Created #{Product.count} products"
