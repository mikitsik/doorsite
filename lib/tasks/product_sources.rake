# frozen_string_literal: true

namespace :product_sources do
  desc 'Create or update production product sources'
  task setup: :environment do
    ProductSource.find_or_create_by!(name: 'Magna XML').update!(
      source_type: 'yml',
      url: 'https://dverimagna.by/wp-content/uploads/feed-yml-0.xml',
      enabled: true,
      sync_strategy: 'scheduled',
      settings: {}
    )

    ProductSource.find_or_create_by!(name: 'Elporta XML').update!(
      source_type: 'xml',
      url: 'https://elporta.by/business/export/xml',
      enabled: true,
      sync_strategy: 'scheduled',
      settings: {}
    )

    puts 'Product sources are ready'
  end
end
