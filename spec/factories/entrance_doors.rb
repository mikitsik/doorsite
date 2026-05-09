# frozen_string_literal: true

FactoryBot.define do
  factory :entrance_door do
    dealer { 'MyString' }
    external_id { 'MyString' }
    title { 'MyString' }
    brand { 'MyString' }
    series { 'MyString' }
    collection { 'MyString' }
    category { 'MyString' }
    use_case { 'MyString' }
    construction_type { 'MyString' }
    thermal_break { false }
    outer_finish { 'MyString' }
    inner_finish { 'MyString' }
    outer_color { 'MyString' }
    inner_color { 'MyString' }
    material { 'MyString' }
    filling { 'MyString' }
    glass { 'MyString' }
    height_mm { 1 }
    width_mm { 1 }
    thickness_mm { 1 }
    metal_thickness_mm { '9.99' }
    opening_side { 'MyString' }
    opening_direction { 'MyString' }
    locks_count { 1 }
    sealing_contours_count { 1 }
    country_of_origin { 'MyString' }
    warranty_months { 1 }
    price { '9.99' }
    source_price { '9.99' }
    old_price { '9.99' }
    currency { 'MyString' }
    image_url { 'MyString' }
    source_url { 'MyString' }
    description { 'MyText' }
    available { false }
    active { false }
    raw_data { '' }
    searchable_text { 'MyText' }
  end
end
