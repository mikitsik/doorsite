# frozen_string_literal: true

require 'csv'
require 'bigdecimal'
require 'securerandom'

module Importers
  class CsvProductImporter
    def initialize(product_source:, file_path:)
      @product_source = product_source
      @file_path = file_path
    end

    def call
      batch = nil
      batch = create_batch

      batch.update!(
        status: 'processing',
        started_at: Time.current
      )

      CSV.foreach(@file_path, headers: true).with_index(2) do |row, line_number|
        import_row(row.to_h, batch)
      rescue StandardError => e
        batch.increment!(:failed_count)
        Rails.logger.error("[CsvProductImporter] line #{line_number}: #{e.class}: #{e.message}")
      end

      batch.update!(
        status: 'done',
        finished_at: Time.current
      )

      @product_source.update!(last_synced_at: Time.current)

      batch
    rescue StandardError => e
      batch&.update!(
        status: 'failed',
        error_message: "#{e.class}: #{e.message}",
        finished_at: Time.current
      )

      raise
    end

    private

    def create_batch
      @product_source.import_batches.create!(
        status: 'pending',
        imported_count: 0,
        updated_count: 0,
        failed_count: 0
      )
    end

    def import_row(raw_row, batch)
      normalized = normalize_row(raw_row)

      product = Product.find_or_initialize_by(
        external_id: normalized[:external_id],
        product_source: @product_source
      )

      is_new_record = product.new_record?

      product.assign_attributes(
        slug: safe_slug(normalized[:base_slug], product),
        title: normalized[:title],
        brand: normalized[:brand],
        category: normalized[:category],
        source_price: normalized[:source_price],
        price: normalized[:price],
        currency: normalized[:currency],
        image_url: normalized[:image_url],
        description: normalized[:description],
        source_url: normalized[:source_url],
        vendor_code: normalized[:vendor_code],
        raw_data: raw_row,
        active: normalized[:active],
        import_batch: batch
      )

      product.save!

      if is_new_record
        batch.increment!(:imported_count)
      else
        batch.increment!(:updated_count)
      end
    end

    def normalize_row(row)
      title = fetch(row, 'title')
      external_id = fetch(row, 'external_id').presence || fetch(row, 'slug').presence || title.to_s.parameterize
      base_slug = fetch(row, 'slug').presence || title.to_s.parameterize

      {
        external_id: external_id,
        base_slug: base_slug,
        title: title,
        brand: fetch(row, 'brand'),
        category: fetch(row, 'category'),
        source_price: decimal(fetch(row, 'source_price').presence || fetch(row, 'price')),
        price: decimal(fetch(row, 'price').presence || fetch(row, 'source_price')),
        currency: fetch(row, 'currency').presence || 'BYN',
        image_url: fetch(row, 'image_url'),
        description: fetch(row, 'description'),
        source_url: fetch(row, 'source_url'),
        vendor_code: fetch(row, 'vendor_code'),
        active: parse_boolean(fetch(row, 'active'))
      }
    end

    def safe_slug(base_slug, product)
      normalized_base = base_slug.to_s.parameterize.presence || 'product'

      return product.slug if product.persisted? && product.slug.present?

      candidate = normalized_base

      return candidate unless Product.where(slug: candidate).where.not(id: product.id).exists?

      source_prefix = @product_source.name.to_s.parameterize.presence || 'source'
      candidate = "#{source_prefix}-#{normalized_base}"

      return candidate unless Product.where(slug: candidate).where.not(id: product.id).exists?

      suffix = product.external_id.to_s.parameterize.presence || SecureRandom.hex(4)
      "#{source_prefix}-#{normalized_base}-#{suffix}"
    end

    def fetch(row, key)
      row[key].to_s.strip
    end

    def decimal(value)
      return nil if value.blank?

      normalized = value.to_s.tr(',', '.').gsub(/[^\d.]/, '')
      normalized.presence&.to_d
    end

    # rubocop:disable Naming/PredicateMethod
    def parse_boolean(value)
      return true if value.blank?

      %w[true 1 yes да].include?(value.to_s.downcase)
    end
    # rubocop:enable Naming/PredicateMethod
  end
end
