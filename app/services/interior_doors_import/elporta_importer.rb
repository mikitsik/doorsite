# frozen_string_literal: true

require_relative 'elporta/category_resolver'
require_relative 'elporta/media_resolver'
require_relative 'elporta/description_builder'

module InteriorDoorsImport
  class ElportaImporter < BaseImporter
    include Elporta::CategoryResolver
    include Elporta::MediaResolver
    include Elporta::DescriptionBuilder

    DEALER = 'elporta'
    BRAND = 'Elporta'

    private

    def each_item(&)
      doc.css('catalog products product').each(&)
    end

    def map_item(product)
      category_id = text(product, 'category_id')
      return unless interior_category?(category_id)

      source_price = decimal(text(product, 'price'))
      title = text(product, 'title')
      color_id = text(product, 'color_id')

      {
        dealer: DEALER,
        external_id: text(product, 'id'),
        slug: nil,
        title: title,
        brand: BRAND,
        series: category_name(category_id),
        collection: top_series(category_id),
        category: category_name(category_id),
        variant_group_key: variant_group_key(title, category_id),
        variant_name: color_name(color_id),
        variant_color: color_name(color_id),
        material: material(category_id, product),
        finish: finish(category_id, product),
        glass: glass_name(text(product, 'glass_id')),
        height_mm: option_height(product),
        width_mm: option_width(product),
        thickness_mm: property_number(product, ['Толщина полотна', 'Толщина полотна/коробки', 'Толщина, мм']),
        price: source_price,
        source_price: source_price,
        old_price: decimal(text(product, 'old_price')),
        currency: 'BYN',
        image_url: image_url(product),
        image_thumbnail_url: image_thumbnail_url(product),
        image_medium_url: image_medium_url(product),
        image_original_url: image_original_url(product),
        source_url: text(product, 'url'),
        description: description(product),
        available: text(product, 'archive') != '1',
        active: true,
        raw_data: raw_data(product)
      }
    end

    def categories
      @categories ||= doc.css('catalog categories category').to_h do |category|
        [
          text(category, 'id'),
          {
            title: text(category, 'title'),
            parent_id: text(category, 'parent_id')
          }
        ]
      end
    end

    def colors
      @colors ||= doc.css('catalog colors color').to_h do |color|
        [text(color, 'id'), text(color, 'title')]
      end
    end

    def glasses
      @glasses ||= doc.css('catalog glasses glass').to_h do |glass|
        [text(glass, 'id'), text(glass, 'title')]
      end
    end

    def properties
      @properties ||= doc.css('catalog properties property').to_h do |property|
        [text(property, 'id'), text(property, 'title')]
      end
    end

    def property_values
      @property_values ||= doc.css('catalog > propertyValues > propertyValue').to_h do |property_value|
        [
          text(property_value, 'id'),
          {
            title: text(property_value, 'title'),
            property_id: text(property_value, 'property_id') || text(property_value, 'propertyId')
          }
        ]
      end
    end

    def product_property_values(product)
      product.css('> propertyValues > propertyValue').filter_map do |property_value|
        property_values[text(property_value, 'id')]
      end
    end

    def variant_group_key(title, category_id)
      "#{DEALER}:#{category_id}:#{title.to_s.parameterize}"
    end

    def color_name(color_id)
      colors[color_id]
    end

    def glass_name(glass_id)
      glasses[glass_id]
    end

    def property_number(product, titles)
      node = product_property_values(product).find do |property|
        title = property_title(property)
        titles.any? { |expected| title.to_s.downcase.include?(expected.downcase) }
      end

      return if node.blank?

      property_value(node).to_s[/\d+/]&.to_i
    end

    def option_height(product)
      parse_option_size(product)&.first
    end

    def option_width(product)
      parse_option_size(product)&.last
    end

    def parse_option_size(product)
      option = product.at_css('options option title')&.text
      return if option.blank?

      match = option.match(/(\d+)\*(\d+)/)
      return unless match

      [match[1].to_i * 10, match[2].to_i * 10]
    end

    def raw_data(product)
      {
        category_id: text(product, 'category_id'),
        color_id: text(product, 'color_id'),
        glass_id: text(product, 'glass_id'),
        description_blocks: description_blocks(product),
        category_path: path_titles(text(product, 'category_id')),
        properties: raw_properties(product)
      }
    end

    def raw_properties(product)
      product_property_values(product).map do |property_value|
        {
          property_id: property_value[:property_id],
          property: property_name(property_value[:property_id]),
          title: property_value[:title]
        }
      end
    end
  end
end
