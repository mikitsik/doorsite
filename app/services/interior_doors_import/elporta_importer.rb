# frozen_string_literal: true

module InteriorDoorsImport
  class ElportaImporter < BaseImporter
    DEALER = 'elporta'
    INTERIOR_ROOT_ID = '42'

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
        brand: 'Elporta',
        series: category_name(category_id),
        collection: top_series(category_id),
        category: category_name(category_id),
        variant_group_key: variant_group_key(title, category_id),
        variant_name: color_name(color_id),
        variant_color: color_name(color_id),
        material: material(category_id),
        finish: finish(category_id),
        glass: glass_name(text(product, 'glass_id')),
        height_mm: option_height(product),
        width_mm: option_width(product),
        thickness_mm: property_number(product, %w[
                                        Толщина полотна
                                        Толщина двери
                                      ]),
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

    def interior_category?(category_id)
      path_ids(category_id).include?(INTERIOR_ROOT_ID)
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
        [
          text(color, 'id'),
          text(color, 'title')
        ]
      end
    end

    def glasses
      @glasses ||= doc.css('catalog glasses glass').to_h do |glass|
        [
          text(glass, 'id'),
          text(glass, 'title')
        ]
      end
    end

    def property_values
      @property_values ||= doc.css('catalog propertyValues propertyValue').group_by do |node|
        text(node, 'product_id')
      end
    end

    def category_name(category_id)
      categories.dig(category_id, :title)
    end

    def path_ids(category_id)
      ids = []
      current_id = category_id

      while current_id.present?
        ids << current_id
        current_id = categories.dig(current_id, :parent_id)
      end

      ids
    end

    def top_series(category_id)
      path = path_ids(category_id)

      return unless path.length >= 2

      category_name(path.first)
    end

    def variant_group_key(title, category_id)
      normalized_title = title.to_s.parameterize

      "#{DEALER}:#{category_id}:#{normalized_title}"
    end

    def color_name(color_id)
      colors[color_id]
    end

    def glass_name(glass_id)
      glasses[glass_id]
    end

    def material(category_id)
      path_titles(category_id).find do |title|
        [
          'Эко Шпон',
          'Полипропилен',
          'Эксимер',
          'Флекс Эмаль',
          'Массив',
          'Винил',
          'Хард Флекс',
          'Эмалит',
          'CPL',
          'Финиш Флекс',
          'Шпон'
        ].any? { |keyword| title.include?(keyword) }
      end
    end

    def finish(category_id)
      material(category_id)
    end

    def path_titles(category_id)
      path_ids(category_id).map { |id| category_name(id) }.compact
    end

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

    def description(product)
      description_value = product_property_values(product).find do |node|
        text(node, 'title') == 'Описание'
      end

      return if description_value.blank?

      clean_html(text(description_value, 'value'))
    end

    def property_number(product, titles)
      node = product_property_values(product).find do |property|
        titles.include?(text(property, 'title'))
      end

      return if node.blank?

      text(node, 'value').to_s[/\d+/]&.to_i
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

      [
        match[1].to_i * 10,
        match[2].to_i * 10
      ]
    end

    def product_property_values(product)
      property_values[text(product, 'id')] || []
    end

    def raw_data(product)
      {
        category_id: text(product, 'category_id'),
        color_id: text(product, 'color_id'),
        glass_id: text(product, 'glass_id'),
        properties: product_property_values(product).map do |node|
          {
            title: text(node, 'title'),
            value: text(node, 'value')
          }
        end
      }
    end
  end
end
