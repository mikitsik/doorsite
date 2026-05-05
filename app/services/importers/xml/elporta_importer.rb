# frozen_string_literal: true

module Importers
  module Xml
    class ElportaImporter < BaseImporter
      DEALER = 'Elporta'
      BRAND = 'Elporta'

      private

      def each_item
        doc.css('catalog products product')
      end

      def map_item(product)
        category_id = text(product, 'category_id')
        source_category = category_name(category_id)

        source_price = decimal(text(product, 'price'))
        old_price = decimal(text(product, 'old_price'))

        {
          external_id: text(product, 'id'),
          slug: build_slug(product),
          title: text(product, 'title'),
          brand: BRAND,
          dealer: DEALER,
          door_type: map_door_type(source_category),
          category: map_category(source_category),
          collection: source_category,
          source_price: source_price,
          price: source_price,
          old_price: old_price,
          discount: decimal(text(product, 'discount')) || calculate_discount(source_price, old_price),
          currency: 'BYN',
          image_url: image_url(product),
          source_url: text(product, 'url'),
          description: description(product),
          vendor_code: nil,
          color: color_name(text(product, 'color_id')),
          material: material(product),
          finish: finish(product, source_category),
          glass: glass_name(text(product, 'glass_id')),
          country_of_origin: 'Беларусь',
          source_category: source_category,
          source_category_id: category_id,
          available: true,
          active: true,
          raw_data: raw_data(product),
          searchable_text: searchable_text(product, source_category)
        }
      end

      def categories
        @categories ||= doc.css('categories category').each_with_object({}) do |category, hash|
          id = text(category, 'id')
          hash[id] = text(category, 'title')
        end
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
        @properties ||= doc
                        .xpath('/catalog/properties/property')
                        .each_with_object({}) do |property, hash|
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
        categories[category_id.to_s]
      end

      def color_name(color_id)
        colors[color_id.to_s]
      end

      def glass_name(glass_id)
        glasses[glass_id.to_s]
      end

      def image_url(product)
        %w[original medium thumbnail].filter_map do |size|
          text(product, "pictures picture #{size}")
        end.first
      end

      def description(product)
        values = resolved_property_values(product)

        return nil if values.blank?

        values.map { |item| "#{item[:property]}: #{item[:value]}" }
              .compact
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

      def map_door_type(source_category)
        source = source_category.to_s.downcase

        return 'interior' if source.match?(/межкомнат/)
        return 'entrance' if source.match?(/вход/)

        'unknown'
      end

      def map_category(source_category)
        case map_door_type(source_category)
        when 'interior'
          'Межкомнатные двери'
        when 'entrance'
          'Входные двери'
        else
          'Другое'
        end
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

      def text(node, selector)
        node.at_css(selector)&.text&.squish.presence
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

      def raw_data(product)
        {
          'id' => text(product, 'id'),
          'title' => text(product, 'title'),
          'url' => text(product, 'url'),
          'category_id' => text(product, 'category_id'),
          'category_name' => category_name(text(product, 'category_id')),
          'color_id' => text(product, 'color_id'),
          'color_name' => color_name(text(product, 'color_id')),
          'glass_id' => text(product, 'glass_id'),
          'glass_name' => glass_name(text(product, 'glass_id')),
          'price' => text(product, 'price'),
          'old_price' => text(product, 'old_price'),
          'discount' => text(product, 'discount'),
          'label' => text(product, 'label'),
          'image_url' => image_url(product),
          'properties' => resolved_property_values(product)
        }
      end

      def searchable_text(product, source_category)
        [
          text(product, 'title'),
          BRAND,
          DEALER,
          map_category(source_category),
          source_category,
          color_name(text(product, 'color_id')),
          glass_name(text(product, 'glass_id')),
          material(product),
          finish(product, source_category),
          description(product)
        ].compact.join(' ').squish
      end
    end
  end
end
