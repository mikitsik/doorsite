# frozen_string_literal: true

module InteriorDoorsImport
  module Elporta
    module MediaResolver
      private

      def image_url(product)
        image_original_url(product) ||
          image_medium_url(product) ||
          image_thumbnail_url(product)
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
    end
  end
end
