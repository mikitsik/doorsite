# frozen_string_literal: true

require 'base64'
require 'csv'

encoded = ENV.fetch('PRODUCTS_CSV_BASE64', nil)
raise 'No PRODUCTS_CSV_BASE64' if encoded.blank?

csv_data = Base64.decode64(encoded)

CSV.parse(csv_data, headers: true) do |row|
  Product.find_or_create_by!(slug: row['slug']) do |p|
    p.title = row['title']
    p.brand = row['brand']
    p.category = row['category']
    p.price = row['price']
    p.currency = row['currency']
    p.image_url = row['image_url']
    p.description = row['description']
    p.active = row['active'] == 'true'
  end
end

Rails.logger.debug { "Seeded #{Product.count} products" }
