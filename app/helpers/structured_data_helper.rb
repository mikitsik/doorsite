# frozen_string_literal: true

module StructuredDataHelper
  def product_json_ld(product:, url:)
    image = product_image_url(product)

    {
      '@context': 'https://schema.org',
      '@type': 'Product',
      name: product_name(product),
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
        priceCurrency: 'BYN',
        price: product_price(product).to_s,
        availability: 'https://schema.org/InStock',

        shippingDetails: {
          '@type': 'OfferShippingDetails',
          shippingDestination: {
            '@type': 'DefinedRegion',
            addressCountry: 'BY'
          }
        },

        hasMerchantReturnPolicy: {
          '@type': 'MerchantReturnPolicy',

          applicableCountry: 'BY',
          returnPolicyCategory: 'https://schema.org/MerchantReturnFiniteReturnWindow',

          merchantReturnDays: 14,

          returnMethod: 'https://schema.org/ReturnInStore',

          returnFees: 'https://schema.org/FreeReturn'
        }
      }
    }.compact.to_json
  end

  def organization_json_ld
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'ДВЕРНОЙ.БЕЛ',
      url: 'https://дверной.бел',
      logo: 'https://xn--b1adeqtgm.xn--90ais/android-chrome-512x512.png'
    }.to_json
  end

  private

  def product_name(product)
    product.try(:display_title).presence || product.try(:title).presence || product.try(:source_title).to_s
  end

  def product_price(product)
    product.try(:price).presence || product.try(:source_price)
  end

  def product_image_url(product)
    image =
      product.try(:image_original_url).presence ||
      product.try(:image_medium_url).presence ||
      product.try(:image_url).presence ||
      product.try(:image_thumbnail_url).presence

    image&.start_with?('http') ? image : nil
  end
end
