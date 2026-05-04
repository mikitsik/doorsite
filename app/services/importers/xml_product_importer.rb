# frozen_string_literal: true

require 'nokogiri'
require 'bigdecimal'
require 'securerandom'

module Importers
  class XmlProductImporter
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

      doc = Nokogiri::XML(File.read(@file_path))

      if doc.at_css('yml_catalog')
        import_yml(doc, batch)
      elsif doc.css('catalog products product').any?
        import_elporta(doc, batch)
      else
        raise 'Unknown XML format'
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

    def import_yml(doc, batch)
      categories = doc.css('category').to_h do |category|
        [category['id'], category.text.to_s.squish]
      end

      doc.css('offer').each_with_index do |offer, index|
        raw_data = yml_offer_to_hash(offer)

        data = {
          external_id: offer['id'].to_s.strip,
          title: text(offer, 'name'),
          brand: infer_brand(text(offer, 'name')),
          category: categories[text(offer, 'categoryId')] || 'Двери',
          source_price: decimal(text(offer, 'price')),
          price: decimal(text(offer, 'price')),
          currency: text(offer, 'currencyId').presence || 'BYN',
          image_url: text(offer, 'picture'),
          description: text(offer, 'description'),
          source_url: text(offer, 'url'),
          vendor_code: text(offer, 'vendorCode'),
          active: offer['available'] != 'false',
          raw_data: raw_data
        }

        import_product(data, batch)
      rescue StandardError => e
        batch.increment!(:failed_count)
        Rails.logger.error("[XmlProductImporter:YML] offer #{index + 1}: #{e.class}: #{e.message}")
      end
    end

    def import_elporta(doc, batch)
      doc.css('catalog products product').each_with_index do |product_node, index|
        title = text(product_node, 'title')
        url = text(product_node, 'url')

        data = {
          external_id: text(product_node, 'id'),
          title: title,
          brand: 'Elporta',
          category: 'Двери',
          source_price: decimal(text(product_node, 'price')),
          price: decimal(text(product_node, 'price')),
          currency: 'BYN',
          image_url: text(product_node, 'pictures picture original').presence ||
                     text(product_node, 'pictures picture medium').presence ||
                     text(product_node, 'pictures picture thumbnail'),
          description: title,
          source_url: url,
          vendor_code: text(product_node, 'id'),
          active: true,
          raw_data: elporta_product_to_hash(product_node)
        }

        import_product(data, batch)
      rescue StandardError => e
        batch.increment!(:failed_count)
        Rails.logger.error("[XmlProductImporter:Elporta] product #{index + 1}: #{e.class}: #{e.message}")
      end
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

      if is_new_record
        batch.increment!(:imported_count)
      else
        batch.increment!(:updated_count)
      end
    end

    def text(node, selector)
      node.at_css(selector)&.text.to_s.squish
    end

    def decimal(value)
      return nil if value.blank?

      normalized = value.to_s.tr(',', '.').gsub(/[^\d.]/, '')
      normalized.presence&.to_d
    end

    def infer_brand(title)
      downcased = title.to_s.downcase

      return 'Промет' if downcased.include?('промет')
      return 'МагнаБел' if downcased.include?('магнабел')
      return 'MAGNA' if downcased.include?('magna')

      @product_source.name
    end

    def yml_offer_to_hash(offer)
      children_to_hash(offer).merge(
        'id' => offer['id'],
        'available' => offer['available']
      )
    end

    def elporta_product_to_hash(product_node)
      children_to_hash(product_node)
    end

    def children_to_hash(node)
      node.element_children.each_with_object({}) do |child, hash|
        key = child.name
        value =
          if child.element_children.any?
            children_to_hash(child)
          else
            child.text.to_s.squish
          end

        hash[key] = if hash[key].present?
                      Array(hash[key]) << value
                    else
                      value
                    end
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
  end
end
