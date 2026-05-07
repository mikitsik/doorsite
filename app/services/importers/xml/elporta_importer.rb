# frozen_string_literal: true

module Importers
  module Xml
    class ElportaImporter < BaseImporter
      include CatalogTreeClassifier
      include CategoryPathNormalizer

      DEALER = 'Elporta'
      BRAND = 'Elporta'

      private

      def each_item
        doc.css('catalog products product')
      end

      def map_item(product)
        category_id = text(product, 'category_id')
        raw_category_path = category_path(category_id)
        catalog_section = catalog_section_for(product, raw_category_path)
        normalized_path = normalized_category_path(raw_category_path, catalog_section)

        base_product_data(product, catalog_section).merge(
          catalog_data(category_id, normalized_path, catalog_section),
          price_data(product),
          product_details(product),
          import_data(product, normalized_path, catalog_section)
        )
      end

      def base_product_data(product, catalog_section)
        {
          external_id: text(product, 'id'),
          slug: build_slug(product),
          title: text(product, 'title'),
          brand: BRAND,
          dealer: DEALER,
          door_type: catalog_section,
          catalog_section: catalog_section,
          category: catalog_section_title(catalog_section),
          collection: category_name(text(product, 'category_id'))
        }
      end

      def catalog_data(category_id, normalized_path, _catalog_section)
        source_category = category_name(category_id)

        {
          catalog_source: source_key,
          source_category: source_category,
          source_category_title: source_category,
          source_category_id: category_id,
          source_category_path: normalized_path
        }
      end

      def price_data(product)
        source_price = decimal(text(product, 'price'))
        old_price = decimal(text(product, 'old_price'))

        {
          source_price: source_price,
          price: source_price,
          old_price: old_price,
          discount: decimal(text(product, 'discount')) || calculate_discount(source_price, old_price),
          currency: 'BYN'
        }
      end

      def product_details(product)
        source_category = category_name(text(product, 'category_id'))

        {
          image_url: image_url(product),
          image_thumbnail_url: image_thumbnail_url(product),
          image_medium_url: image_medium_url(product),
          image_original_url: image_original_url(product),
          source_url: text(product, 'url'),
          description: description(product),
          vendor_code: nil,
          color: color_name(text(product, 'color_id')),
          material: material(product),
          finish: finish(product, source_category),
          glass: glass_name(text(product, 'glass_id')),
          country_of_origin: 'Беларусь',
          available: true,
          active: true
        }
      end

      def import_data(product, normalized_path, catalog_section)
        source_category = category_name(text(product, 'category_id'))

        {
          raw_data: raw_data(product, normalized_path),
          searchable_text: searchable_text(product, source_category, catalog_section)
        }
      end

      def catalog_section_for(product, path)
        source = [
          category_path_text(path),
          text(product, 'title'),
          color_name(text(product, 'color_id')),
          glass_name(text(product, 'glass_id')),
          description(product)
        ].compact.join(' ')

        map_catalog_section(source)
      end

      def categories
        @categories ||= doc.css('categories category').each_with_object({}) do |category, hash|
          id = text(category, 'id')

          hash[id] = {
            id: id,
            title: text(category, 'title'),
            parent_id: text(category, 'parent_id'),
            position: text(category, 'position')
          }
        end
      end

      def category_path(category_id)
        path = []
        current = categories[category_id.to_s]

        while current.present?
          path.unshift(
            source: source_key,
            source_category_id: current[:id],
            title: current[:title],
            position: current[:position]
          )

          current = categories[current[:parent_id].to_s]
        end

        path
      end

      def colors
        @colors ||= doc.css('colors color').each_with_object({}) do |color, hash|
          id = text(color, 'id')
          hash[id] = text(color, 'title')
        end
      end

      def glasses
        @glasses ||= doc.css('glasses color').each_with_object({}) do |glass, hash|
          id = text(glass, 'id')
          hash[id] = text(glass, 'title')
        end
      end

      def properties
        @properties ||= doc.xpath('/catalog/properties/property').each_with_object({}) do |property, hash|
          id = text(property, 'id')
          hash[id] = text(property, 'title')
        end
      end

      def property_values
        @property_values ||= doc
                             .xpath('/catalog/propertyValues/propertyValue')
                             .each_with_object({}) do |property_value, hash|
          id = text(property_value, 'id')

          hash[id] = {
            'property_id' => text(property_value, 'property_id'),
            'title' => text(property_value, 'title')
          }
        end
      end

      def category_name(category_id)
        categories.dig(category_id.to_s, :title)
      end

      def color_name(color_id)
        colors[color_id.to_s]
      end

      def glass_name(glass_id)
        glasses[glass_id.to_s]
      end

      def image_thumbnail_url(product)
        text(product, 'pictures picture thumbnail')
      end

      def image_medium_url(product)
        text(product, 'pictures picture medium')
      end

      def image_original_url(product)
        text(product, 'pictures picture original')
      end

      def image_url(product)
        image_medium_url(product) || image_original_url(product) || image_thumbnail_url(product)
      end

      def description(product)
        values = resolved_property_values(product)

        return nil if values.blank?

        values.map { |item| "#{item[:property]}: #{item[:value]}" }
              .join('. ')
              .squish
              .presence
      end

      def material(product)
        find_property_value(product, /материал|массив|шпон|покрытие|отделка/i)
      end

      def finish(product, source_category)
        find_property_value(product, /покрытие|отделка|эмаль|шпон|полипропилен|экошпон|эко шпон/i) ||
          source_category
      end

      def find_property_value(product, pattern)
        resolved_property_values(product)
          .find { |item| item[:property].to_s.match?(pattern) || item[:value].to_s.match?(pattern) }
          &.dig(:value)
      end

      def resolved_property_values(product)
        product.xpath('./propertyValues/propertyValue/id').filter_map do |id_node|
          value_id = id_node.text.to_s.squish
          property_value = property_values[value_id]
          next if property_value.blank?

          property_id = property_value['property_id']

          {
            property: properties[property_id],
            value: property_value['title']
          }
        end
      end

      def decimal(value)
        return nil if value.blank?

        BigDecimal(value.to_s.tr(',', '.'))
      end

      def calculate_discount(price, old_price)
        return nil if price.blank? || old_price.blank? || old_price.zero?

        (((old_price - price) / old_price) * 100).round(2)
      end

      def build_slug(product)
        base = [
          DEALER,
          text(product, 'id'),
          text(product, 'title'),
          color_name(text(product, 'color_id'))
        ].compact.join(' ')

        base.parameterize
      end

      def raw_data(product, normalized_path)
        {
          'id' => text(product, 'id'),
          'title' => text(product, 'title'),
          'url' => text(product, 'url'),
          'category_id' => text(product, 'category_id'),
          'category_name' => category_name(text(product, 'category_id')),
          'category_path' => normalized_path,
          'color_id' => text(product, 'color_id'),
          'color_name' => color_name(text(product, 'color_id')),
          'glass_id' => text(product, 'glass_id'),
          'glass_name' => glass_name(text(product, 'glass_id')),
          'price' => text(product, 'price'),
          'old_price' => text(product, 'old_price'),
          'discount' => text(product, 'discount'),
          'label' => text(product, 'label'),
          'image_url' => image_url(product),
          'image_thumbnail_url' => image_thumbnail_url(product),
          'image_medium_url' => image_medium_url(product),
          'image_original_url' => image_original_url(product),
          'properties' => resolved_property_values(product)
        }
      end

      def searchable_text(product, source_category, catalog_section)
        [
          text(product, 'title'),
          BRAND,
          DEALER,
          catalog_section_title(catalog_section),
          source_category,
          color_name(text(product, 'color_id')),
          glass_name(text(product, 'glass_id')),
          material(product),
          finish(product, source_category),
          description(product)
        ].compact.join(' ').squish
      end

      def source_key
        'elporta'
      end
    end
  end
end
