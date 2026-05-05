# frozen_string_literal: true

module Importers
  module Xml
    class YmlImporter < BaseImporter
      private

      def each_item
        doc.css('offer')
      end

      def map_item(offer)
        title = text(offer, 'name')

        {
          external_id: offer['id'].to_s.strip,
          title: title,
          brand: infer_brand(title),
          category: categories[text(offer, 'categoryId')] || 'Двери',
          source_price: decimal(text(offer, 'price')),
          price: decimal(text(offer, 'price')),
          currency: text(offer, 'currencyId').presence || 'BYN',
          image_url: text(offer, 'picture'),
          description: text(offer, 'description'),
          source_url: text(offer, 'url'),
          vendor_code: text(offer, 'vendorCode'),
          active: offer['available'] != 'false',
          raw_data: children_to_hash(offer).merge(
            'id' => offer['id'],
            'available' => offer['available']
          )
        }
      end

      def categories
        @categories ||= doc.css('category').to_h do |category|
          [category['id'], category.text.to_s.squish]
        end
      end

      def infer_brand(title)
        downcased = title.to_s.downcase

        return 'Промет' if downcased.include?('промет')
        return 'МагнаБел' if downcased.include?('магнабел')
        return 'MAGNA' if downcased.include?('magna')

        @product_source.name
      end
    end
  end
end
