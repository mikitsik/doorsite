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
        catalog_category = find_or_create_catalog_category(data)

        product.assign_attributes(product_attributes(data, product, batch, catalog_category))
        product.save!

        increment_counter(batch, is_new_record ? :imported_count : :updated_count)

        product
      end

      def product_attributes(data, product, batch, catalog_category)
        {
          slug: safe_slug(data, product),
          title: data[:title],
          brand: data[:brand],
          dealer: data[:dealer],
          door_type: data[:door_type],
          category: data[:category],
          collection: data[:collection],
          catalog_category: catalog_category,
          catalog_section: data[:catalog_section],
          source_price: data[:source_price],
          price: data[:price],
          old_price: data[:old_price],
          discount: data[:discount],
          currency: data[:currency],
          image_url: data[:image_url],
          description: data[:description],
          source_url: data[:source_url],
          vendor_code: data[:vendor_code],
          color: data[:color],
          material: data[:material],
          finish: data[:finish],
          glass: data[:glass],
          country_of_origin: data[:country_of_origin],
          source_category: data[:source_category],
          source_category_id: data[:source_category_id],
          source_category_title: data[:source_category_title],
          source_category_path: data[:source_category_path],
          available: data[:available],
          raw_data: data[:raw_data],
          searchable_text: data[:searchable_text],
          active: data[:active],
          import_batch: batch
        }.compact
      end

      def find_or_create_catalog_category(data)
        path = data[:source_category_path]
        return nil if path.blank?

        parent = nil

        path.each_with_index do |node, index|
          parent = upsert_catalog_category(
            node: node,
            parent: parent,
            depth: index,
            full_path: path.first(index + 1),
            data: data
          )
        end

        parent
      end

      def upsert_catalog_category(node:, parent:, depth:, full_path:, data:)
        source = data[:catalog_source]
        source_category_id = node[:id].to_s

        category = CatalogCategory.find_or_initialize_by(
          source: source,
          source_category_id: source_category_id
        )

        category.assign_attributes(
          slug: catalog_category_slug(source, source_category_id, node[:title]),
          title: node[:title],
          kind: data[:catalog_section],
          parent: parent,
          position: node[:position].presence || 0,
          depth: depth,
          path: full_path,
          active: true
        )

        category.save!
        category
      end

      def catalog_category_slug(source, source_category_id, title)
        [
          source,
          source_category_id,
          title
        ].compact.join(' ').parameterize
      end

      def increment_counter(batch, counter)
        batch.increment!(counter)
      end

      def text(node, selector)
        node.at_css(selector)&.text.to_s.squish.presence
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

      def safe_slug(data, product)
        return product.slug if product.persisted? && product.slug.present?

        base = data[:slug].presence || data[:title]
        normalized_base = normalize_slug(base)

        return normalized_base unless slug_exists?(normalized_base, product)

        with_source = with_source_prefix(normalized_base)
        return with_source unless slug_exists?(with_source, product)

        with_suffix(with_source, data)
      end

      def normalize_slug(value)
        value.to_s.parameterize.presence || 'product'
      end

      def with_source_prefix(slug)
        source_prefix = @product_source.name.to_s.parameterize.presence || 'source'
        "#{source_prefix}-#{slug}"
      end

      def with_suffix(slug, data)
        suffix = data[:external_id].to_s.parameterize.presence || SecureRandom.hex(4)
        "#{slug}-#{suffix}"
      end

      def slug_exists?(slug, product)
        Product.where(slug:).where.not(id: product.id).exists?
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
