# frozen_string_literal: true

require_relative 'color_normalizer'

module InteriorDoorsImport
  class ElportaImporter < BaseImporter
    DEALER = 'elporta'
    BRAND = 'Elporta'
    INTERIOR_ROOT_ID = '42'

    private

    def each_item(&)
      doc.css('catalog products product').each(&)
    end

    def map_item(product)
      category_id = text(product, 'category_id')
      return unless interior_category?(category_id)
      return if archived?(product)

      source_title = text(product, 'title')
      vendor_color = color_name(text(product, 'color_id'))

      {
        dealer: DEALER,
        external_id: text(product, 'id'),
        slug: nil,
        source_title: source_title,
        brand: BRAND,
        series: series_name(category_id),
        door_model: door_model(source_title, vendor_color),
        vendor_color: vendor_color,
        hint_tone: ColorNormalizer.call(vendor_color),
        material: material(product, category_id),
        glass: glass_name(text(product, 'glass_id')),
        height_mm: option_height(product),
        width_mm: option_width(product),
        thickness_mm: property_number(product, ['Толщина полотна', 'Толщина полотна/коробки', 'Толщина, мм']),
        source_price: decimal(text(product, 'price')),
        image_url: image_url(product),
        image_thumbnail_url: image_thumbnail_url(product),
        image_medium_url: image_medium_url(product),
        image_original_url: image_original_url(product),
        source_url: text(product, 'url'),
        description: description(product),
        raw_data: raw_data(product, category_id)
      }
    end

    def archived?(product)
      text(product, 'archive') == '1'
    end

    def categories
      @categories ||= doc.css('catalog categories category').to_h do |category|
        [
          text(category, 'id'),
          {
            title: text(category, 'title'),
            parent_id: text(category, 'parent_id').presence || text(category, 'parentId').presence
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
            property_id: text(property_value, 'property_id').presence || text(property_value, 'propertyId').presence
          }
        ]
      end
    end

    def interior_category?(category_id)
      category_path_ids(category_id).include?(INTERIOR_ROOT_ID)
    end

    def category_path_ids(category_id)
      ids = []
      current_id = category_id

      while current_id.present?
        ids << current_id
        current_id = categories.dig(current_id, :parent_id)
      end

      ids
    end

    def category_path_titles(category_id)
      category_path_ids(category_id).reverse.filter_map { |id| categories.dig(id, :title) }
    end

    def series_name(category_id)
      category_path_titles(category_id)[1]
    end

    def vendor_family(category_id)
      category_path_titles(category_id)[2]
    end

    def door_model(source_title, vendor_color)
      source_title.to_s
                  .delete_suffix(vendor_color.to_s)
                  .delete('«')
                  .delete('»')
                  .delete('"')
                  .squish
    end

    def color_name(color_id)
      colors[color_id]
    end

    def glass_name(glass_id)
      glasses[glass_id]
    end

    def material(product, category_id)
      property_value_by_titles(product, ['Материал']) || series_name(category_id)
    end

    def property_number(product, titles)
      property_value_by_titles(product, titles).to_s[/\d+/]&.to_i
    end

    def property_value_by_titles(product, titles)
      product_property_values(product).find do |property_value|
        property_title = properties[property_value[:property_id].to_s]
        titles.any? { |title| property_title.to_s.downcase.include?(title.downcase) }
      end&.dig(:title)
    end

    def product_property_values(product)
      product.css('> propertyValues > propertyValue').filter_map do |property_value|
        property_values[text(property_value, 'id')]
      end
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

    def description(product)
      clean_html(text(product, 'description')).presence ||
        raw_properties(product).pluck(:title).compact_blank.join(' ').squish.presence
    end

    def image_url(product)
      image_original_url(product) || image_medium_url(product) || image_thumbnail_url(product)
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

    def raw_data(product, category_id)
      {
        category_id: category_id,
        category_path: category_path_titles(category_id),
        vendor_family: vendor_family(category_id),
        color_id: text(product, 'color_id'),
        glass_id: text(product, 'glass_id'),
        properties: raw_properties(product),
        archive: text(product, 'archive'),
        source_price: text(product, 'price'),
        old_price: text(product, 'old_price')
      }
    end

    def raw_properties(product)
      product_property_values(product).map do |property_value|
        {
          property_id: property_value[:property_id],
          property: properties[property_value[:property_id].to_s],
          title: property_value[:title]
        }
      end
    end
  end
end
