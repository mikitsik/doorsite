# frozen_string_literal: true

require 'nokogiri'
require 'bigdecimal'
require 'securerandom'

module Importers
  module Xml
    class BaseImporter
      def initialize(product_source:, file_path:)
        @product_source = product_source
        @file_path = file_path
      end

      def call
        batch = nil
        batch = create_batch

        batch.update!(status: 'processing', started_at: Time.current)

        each_item.each.with_index(1) do |item, index|
          import_product(map_item(item), batch)
        rescue StandardError => e
          increment_counter(batch, :failed_count)
          Rails.logger.error("[#{self.class.name}] item #{index}: #{e.class}: #{e.message}")
        end

        batch.update!(status: 'done', finished_at: Time.current)
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

      def doc
        @doc ||= Nokogiri::XML(File.read(@file_path))
      end

      def create_batch
        @product_source.import_batches.create!(
          status: 'pending',
          imported_count: 0,
          updated_count: 0,
          failed_count: 0
        )
      end

      def import_product(data, batch)
        product = Product.find_or_initialize_by(
          external_id: data[:external_id],
          product_source: @product_source
        )

        is_new_record = product.new_record?

        product.assign_attributes(
          slug: safe_slug(data[:title], product),
          title: data[:title],
          brand: data[:brand],
          category: data[:category],
          source_price: data[:source_price],
          price: data[:price],
          currency: data[:currency],
          image_url: data[:image_url],
          description: data[:description],
          source_url: data[:source_url],
          vendor_code: data[:vendor_code],
          raw_data: data[:raw_data],
          active: data[:active],
          import_batch: batch
        )

        product.save!

        increment_counter(batch, is_new_record ? :imported_count : :updated_count)
      end

      def increment_counter(batch, counter)
        batch.increment!(counter)
      end

      def text(node, selector)
        node.at_css(selector)&.text.to_s.squish
      end

      def decimal(value)
        return nil if value.blank?

        normalized = value.to_s.tr(',', '.').gsub(/[^\d.]/, '')
        normalized.presence&.to_d
      end

      def children_to_hash(node)
        node.element_children.each_with_object({}) do |child, hash|
          key = child.name
          value = child.element_children.any? ? children_to_hash(child) : child.text.to_s.squish

          hash[key] = hash[key].present? ? Array(hash[key]) << value : value
        end
      end

      def safe_slug(base, product)
        normalized_base = base.to_s.parameterize.presence || 'product'

        return product.slug if product.persisted? && product.slug.present?

        candidate = normalized_base
        return candidate unless Product.where(slug: candidate).where.not(id: product.id).exists?

        source_prefix = @product_source.name.to_s.parameterize.presence || 'source'
        candidate = "#{source_prefix}-#{normalized_base}"

        return candidate unless Product.where(slug: candidate).where.not(id: product.id).exists?

        suffix = product.external_id.to_s.parameterize.presence || SecureRandom.hex(4)
        "#{source_prefix}-#{normalized_base}-#{suffix}"
      end

      def each_item
        raise NotImplementedError
      end

      def map_item(_item)
        raise NotImplementedError
      end
    end
  end
end
