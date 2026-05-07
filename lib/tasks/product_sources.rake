# frozen_string_literal: true

namespace :product_sources do
  desc 'Create or update product sources'
  task setup: :environment do
    magna = ProductSource.find_or_initialize_by(name: 'Magna XML')
    magna.update!(
      source_type: 'yml',
      url: 'tmp/imports/magna.xml',
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )

    elporta = ProductSource.find_or_initialize_by(name: 'Elporta XML')
    elporta.update!(
      source_type: 'xml',
      url: 'tmp/imports/elporta.xml',
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )

    puts 'Product sources:'
    pp ProductSource.pluck(:name, :source_type, :url, :enabled, :sync_strategy)
  end
end
