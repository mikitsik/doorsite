# frozen_string_literal: true

FactoryBot.define do
  factory :catalog_category do
    slug { 'MyString' }
    title { 'MyString' }
    kind { 'MyString' }
    parent { nil }
    source { 'MyString' }
    source_category_id { 'MyString' }
    position { 1 }
    depth { 1 }
    path { '' }
    active { false }
  end
end
