# frozen_string_literal: true

FactoryBot.define do
  factory :import_batch do
    product_source
    status { 'pending' }
    imported_count { 0 }
    updated_count { 0 }
    failed_count { 0 }
  end
end
