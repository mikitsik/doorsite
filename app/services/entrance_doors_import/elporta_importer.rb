# frozen_string_literal: true

module EntranceDoorsImport
  class ElportaImporter < BaseImporter
    DEALER = 'elporta'
    BRAND = 'Elporta'
    ENTRANCE_ROOT_ID = '62'

    PROPERTY_DESCRIPTION_ID = '61'
    PROPERTY_SEALING_ID = '49'
    PROPERTY_FILLING_ID = '50'
    PROPERTY_THICKNESS_ID = '42'
    PROPERTY_METAL_THICKNESS_ID = '44'
    LOCK_PROPERTY_IDS = %w[62 63 64].freeze
    DESCRIPTION_PROPERTY_IDS = %w[61 94 38 41 39 48 49 74 50 73].freeze

    def call
      doc.css('catalog products product').filter_map do |product|
        next unless entrance_product?(product)

        upsert_entrance_door!(map_product(product))
      end
    end

    private

    def entrance_product?(product)
      root_id_for(text(product, 'category_id')) == ENTRANCE_ROOT_ID
    end

    def map_product(product)
      category_id = text(product, 'category_id')
      category = category_title(category_id)
      source_price = decimal(text(product, 'price'))
      main_option = option_matching_price(product, source_price)
      option_data = parsed_option(main_option)

      {
        dealer: DEALER,
        external_id: text(product, 'id'),
        title: text(product, 'title'),
        brand: BRAND,
        series: category,
        collection: category,
        category: 'Входные двери',

        use_case: 'Входная дверь',
        construction_type: construction_type_from(category),
        thermal_break: false,

        outer_finish: nil,
        inner_finish: nil,
        outer_color: color_name(text(product, 'color_id')),
        inner_color: color_name(text(product, 'color_id')),

        material: material_from(category),
        filling: property_value_title(product, PROPERTY_FILLING_ID),
        glass: glass_name(text(product, 'glass_id')),

        height_mm: option_data[:height_mm],
        width_mm: option_data[:width_mm],
        thickness_mm: integer_from(property_value_title(product, PROPERTY_THICKNESS_ID)),
        metal_thickness_mm: decimal(property_value_title(product, PROPERTY_METAL_THICKNESS_ID)),

        opening_side: option_data[:opening_side],
        opening_direction: nil,

        locks_count: locks_count(product),
        sealing_contours_count: integer_from(property_value_title(product, PROPERTY_SEALING_ID)),
        country_of_origin: 'Беларусь',
        warranty_months: nil,

        price: source_price,
        source_price: source_price,
        old_price: decimal(text(product, 'old_price')),
        currency: 'BYN',

        image_url: image_url(product),
        source_url: text(product, 'url'),
        description: description(product),

        available: available?(product),
        active: true,
        raw_data: raw_product_data(product)
      }
    end

    def categories
      @categories ||= doc.css('categories category').to_h do |category|
        [
          text(category, 'id'),
          {
            title: text(category, 'title'),
            parent_id: text(category, 'parent_id'),
            position: text(category, 'position')
          }
        ]
      end
    end

    def colors
      @colors ||= doc.css('colors color').to_h do |color|
        [text(color, 'id'), text(color, 'title')]
      end
    end

    def glasses
      @glasses ||= doc.css('glasses glass').to_h do |glass|
        [text(glass, 'id'), text(glass, 'title')]
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

    def accessory_groups
      @accessory_groups ||= doc.css('catalog > accessoryGroups > accessoryGroup').to_h do |group|
        [
          text(group, 'id'),
          {
            title: text(group, 'title'),
            quantity: text(group, 'quantity'),
            type: text(group, 'type')
          }
        ]
      end
    end

    def root_id_for(category_id)
      current_id = category_id.to_s

      loop do
        category = categories[current_id]
        return current_id if category.blank? || category[:parent_id].blank?

        current_id = category[:parent_id]
      end
    end

    def category_title(category_id)
      categories.dig(category_id.to_s, :title)
    end

    def color_name(color_id)
      colors[color_id.to_s]
    end

    def glass_name(glass_id)
      glasses[glass_id.to_s]
    end

    def construction_type_from(category)
      return if category.blank?

      category[/\((.+?)\)/, 1] || category
    end

    def material_from(category)
      source = category.to_s.downcase

      return 'Металл / МДФ' if source.include?('металл-мдф')
      return 'МДФ / МДФ' if source.include?('мдф-мдф')

      nil
    end

    def image_url(product)
      text(product, 'pictures picture original') ||
        text(product, 'picture original') ||
        text(product, 'image')
    end

    def description(product)
      description_blocks(product).join(' ').squish.presence
    end

    def description_blocks(product)
      explicit_description = clean_html(text(product, 'description'))
      return [explicit_description] if explicit_description.present?

      DESCRIPTION_PROPERTY_IDS.filter_map do |property_id|
        property_value_title(product, property_id)
      end
    end

    def available?(product)
      label = text(product, 'label')

      label != 'hidden'
    end

    def product_property_values(product)
      product.css('> propertyValues > propertyValue').filter_map do |property_value|
        property_values[text(property_value, 'id')]
      end
    end

    def property_value_title(product, property_id)
      product_property_values(product).find do |property_value|
        property_value[:property_id] == property_id
      end&.dig(:title)
    end

    def locks_count(product)
      product_property_values(product).count do |property_value|
        property_value[:property_id].in?(LOCK_PROPERTY_IDS)
      end.presence
    end

    def option_matching_price(product, source_price)
      options = product.css('> options > option')

      options.find { |option| decimal(text(option, 'price')) == source_price } || options.first
    end

    def parsed_option(option)
      title = text(option, 'title').to_s

      {
        height_mm: option_size_part(title, 0),
        width_mm: option_size_part(title, 1),
        opening_side: option_opening_side(title)
      }
    end

    def option_size_part(title, index)
      size = title[/(\d+)\s*\*\s*(\d+)/, index + 1]
      return if size.blank?

      size.to_i * 10
    end

    def option_opening_side(title)
      return 'Левая' if title.downcase.include?('левая')
      return 'Правая' if title.downcase.include?('правая')

      nil
    end

    def product_options(product)
      product.css('> options > option').map do |option|
        {
          id: text(option, 'id'),
          title: text(option, 'title'),
          price: text(option, 'price'),
          old_price: text(option, 'old_price'),
          label: text(option, 'label')
        }
      end
    end

    def resolved_property_values(product)
      product_property_values(product).map do |property_value|
        {
          property_id: property_value[:property_id],
          title: property_value[:title]
        }
      end
    end

    def resolved_accessory_groups(product)
      product.css('> accessoryGroups > accessoryGroup').filter_map do |group|
        group_id = text(group, 'id')
        data = accessory_groups[group_id]

        next if data.blank?

        {
          id: group_id,
          title: data[:title],
          quantity: data[:quantity],
          type: data[:type]
        }
      end
    end

    def raw_product_data(product)
      {
        id: text(product, 'id'),
        category_id: text(product, 'category_id'),
        root_category_id: root_id_for(text(product, 'category_id')),
        color_id: text(product, 'color_id'),
        glass_id: text(product, 'glass_id'),
        options: product_options(product),
        property_values: resolved_property_values(product),
        accessory_groups: resolved_accessory_groups(product),
        description_blocks: description_blocks(product)
      }
    end
  end
end
