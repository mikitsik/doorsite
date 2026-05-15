# frozen_string_literal: true

module StructuredDataHelper
  def product_json_ld(product:, url:)
    image = product_image_url(product)

    {
      '@context': 'https://schema.org',
      '@type': 'Product',
      name: product.title,
      image: image.present? ? [image] : nil,
      description: product.description.to_s.squish.presence,
      brand: {
        '@type': 'Brand',
        name: product.brand.presence || 'ДВЕРНОЙ.БЕЛ'
      },
      sku: product.external_id.to_s.presence,
      offers: {
        '@type': 'Offer',
        url: url,
        priceCurrency: product.currency.presence || 'BYN',
        price: product.price.to_s,
        availability: 'https://schema.org/InStock'
      }
    }.compact.to_json
  end

  def organization_json_ld
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'ДВЕРНОЙ.БЕЛ',
      url: 'https://дверной.бел',
      logo: 'https://дверной.бел/icon.png'
    }.to_json
  end

  private

  def product_image_url(product)
    image =
      product.try(:image_original_url).presence ||
      product.try(:image_medium_url).presence ||
      product.try(:image_url).presence ||
      product.try(:image_thumbnail_url).presence

    image&.start_with?('http') ? image : nil
  end
end
