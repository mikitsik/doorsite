# frozen_string_literal: true

namespace :imports do
  desc 'Sync all enabled product sources'
  task sync: :environment do
    ProductSource.where(enabled: true, sync_strategy: 'scheduled').find_each do |source|
      puts "Syncing #{source.name}..."

      Importers::SyncProductSource.new(product_source: source).call

      puts "Done #{source.name}"
    rescue StandardError => e
      Rails.logger.error("[imports:sync] #{source.name}: #{e.class}: #{e.message}")
      puts "Failed #{source.name}: #{e.message}"
    end
  end
end
