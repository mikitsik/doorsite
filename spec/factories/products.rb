# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:slug) { |n| "product-#{n}" }
    sequence(:title) { |n| "Дверь #{n}" }
    brand { 'Elporta' }
    category { 'Межкомнатные двери' }
    price { 100.00 }
    currency { 'BYN' }
    image_url { 'https://example.com/image.jpg' }
    description { 'Описание товара' }
    active { true }

    product_source
    import_batch
  end
end
