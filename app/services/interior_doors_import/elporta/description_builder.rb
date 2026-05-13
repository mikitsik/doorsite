# frozen_string_literal: true

module InteriorDoorsImport
  module Elporta
    module DescriptionBuilder
      DESCRIPTION_PROPERTY_IDS = %w[61 38 16 11 40 102].freeze

      private

      def description(product)
        description_blocks(product).join(' ').squish.presence || fallback_description(product)
      end

      def description_blocks(product)
        explicit_description = clean_html(text(product, 'description'))
        return [explicit_description] if explicit_description.present?

        DESCRIPTION_PROPERTY_IDS.filter_map do |property_id|
          property_value_title(product, property_id)
        end
      end

      def property_value_title(product, property_id)
        product_property_values(product).find do |property_value|
          property_value[:property_id] == property_id
        end&.dig(:title)
      end

      def property_name(property_id)
        properties[property_id.to_s]
      end

      def property_title(property_value)
        property_name(property_value[:property_id]) || property_value[:property_id]
      end

      def property_value(property_value)
        property_value[:title]
      end

      def value_from_description_blocks(product, titles)
        product_property_values(product).find do |property_value|
          property_label = property_title(property_value)

          titles.any? { |expected| property_label.to_s.downcase.include?(expected.downcase) }
        end&.dig(:title)
      end

      def fallback_description(product)
        [
          text(product, 'title'),
          category_name(text(product, 'category_id')),
          color_name(text(product, 'color_id')),
          glass_name(text(product, 'glass_id'))
        ].compact_blank.join(' · ').presence
      end
    end
  end
end
