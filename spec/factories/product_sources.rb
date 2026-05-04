# frozen_string_literal: true

FactoryBot.define do
  factory :product_source do
    sequence(:name) { |n| "Source #{n}" }
    source_type { 'xml' }
    url { 'local' }
    enabled { true }
    sync_strategy { 'manual' }
    settings { {} }
  end
end
