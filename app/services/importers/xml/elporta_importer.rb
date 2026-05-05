# frozen_string_literal: true

module Importers
  module Xml
    class ElportaImporter < BaseImporter
      private

      def each_item
        doc.css('catalog products product')
      end

      def map_item(product_node)
        title = text(product_node, 'title')

        {
          external_id: text(product_node, 'id'),
          title: title,
          brand: 'Elporta',
          category: category_title(product_node),
          source_price: decimal(text(product_node, 'price')),
          price: decimal(text(product_node, 'price')),
          currency: 'BYN',
          image_url: image_url(product_node),
          description: title,
          source_url: text(product_node, 'url'),
          vendor_code: text(product_node, 'id'),
          active: true,
          raw_data: children_to_hash(product_node)
        }
      end

      def image_url(product_node)
        text(product_node, 'pictures picture original').presence ||
          text(product_node, 'pictures picture medium').presence ||
          text(product_node, 'pictures picture thumbnail')
      end

      def category_title(product_node)
        categories[text(product_node, 'category_id')] || 'Двери'
      end

      def categories
        @categories ||= doc.css('catalog categories category').to_h do |category|
          [text(category, 'id'), text(category, 'title')]
        end
      end
    end
  end
end
