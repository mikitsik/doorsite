# frozen_string_literal: true

module EntranceDoorsImport
  class MagnaImporter < BaseImporter
    DEALER = 'magna'
    ENTRANCE_ROOT_IDS = %w[586 98].freeze

    def call
      doc.css('offer').filter_map do |offer|
        next unless entrance_offer?(offer)

        upsert_entrance_door!(map_offer(offer))
      end
    end

    private

    def entrance_offer?(offer)
      root_id_for(text(offer, 'categoryId')).in?(ENTRANCE_ROOT_IDS)
    end

    def map_offer(offer)
      source_price = decimal(text(offer, 'price'))

      {
        dealer: DEALER,
        external_id: offer['id'],
        title: text(offer, 'name'),
        brand: param(offer, 'Производитель') || text(offer, 'vendor'),
        series: series_from(offer),
        collection: offer['group_id'],
        category: category_title(text(offer, 'categoryId')),

        use_case: param(offer, 'Назначение двери'),
        construction_type: construction_type_from(offer),
        thermal_break: thermal_break?(offer),

        outer_finish: param(offer, 'Отделка снаружи'),
        inner_finish: param(offer, 'Отделка внутри'),
        outer_color: param(offer, 'Цвет снаружи'),
        inner_color: param(offer, 'Цвет внутри'),

        material: material_from(offer),
        filling: param(offer, 'Наполнение двери'),
        glass: param(offer, 'Стекло'),

        height_mm: integer_from(param(offer, 'Высота (монтажный габарит)')),
        width_mm: integer_from(param(offer, 'Ширина (монтажный габарит)')),
        thickness_mm: integer_from(param(offer, 'Толщина полотна')),
        metal_thickness_mm: decimal(param(offer, 'Толщина металла')),

        opening_side: param(offer, 'Сторона открывания двери'),
        opening_direction: param(offer, 'Направление открывания двери'),

        locks_count: integer_from(param(offer, 'Кол-во замков')),
        sealing_contours_count: integer_from(param(offer, 'Кол-во контуров уплотнения')),
        country_of_origin: text(offer, 'country_of_origin') || param(offer, 'Страна производитель'),
        warranty_months: integer_from(param(offer, 'Гарантийный срок')),

        price: source_price,
        source_price: source_price,
        old_price: decimal(text(offer, 'oldprice')),
        currency: text(offer, 'currencyId') || 'BYN',

        image_url: text(offer, 'picture'),
        source_url: text(offer, 'url'),
        description: clean_html(text(offer, 'description')),

        available: offer['available'] != 'false',
        active: true,
        raw_data: raw_offer_data(offer)
      }
    end

    def categories
      @categories ||= doc.css('category').to_h do |category|
        [
          category['id'],
          {
            title: category.text.strip,
            parent_id: category['parentId']
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

    def param(offer, name)
      offer.css('param').find { |node| node['name'] == name }&.text&.strip.presence
    end

    def series_from(offer)
      title = text(offer, 'name').to_s

      title[/["«](.+?)["»]/, 1] || text(offer, 'vendor')
    end

    def construction_type_from(offer)
      [
        param(offer, 'Назначение двери'),
        param(offer, 'Отделка снаружи'),
        param(offer, 'Отделка внутри'),
        category_title(text(offer, 'categoryId'))
      ].compact_blank.join(' / ')
    end

    def thermal_break?(offer)
      [
        param(offer, 'Назначение двери'),
        category_title(text(offer, 'categoryId')),
        text(offer, 'name')
      ].compact_blank.join(' ').downcase.include?('термо')
    end

    def material_from(offer)
      [
        param(offer, 'Отделка снаружи'),
        param(offer, 'Отделка внутри')
      ].compact_blank.join(' / ').presence
    end

    def raw_offer_data(offer)
      {
        id: offer['id'],
        group_id: offer['group_id'],
        category_id: text(offer, 'categoryId'),
        root_category_id: root_id_for(text(offer, 'categoryId')),
        vendor_code: text(offer, 'vendorCode'),
        params: offer.css('param').to_h { |param| [param['name'], param.text.strip] }
      }
    end
  end
end
