# frozen_string_literal: true

module InteriorDoorsImport
  class MagnaImporter < BaseImporter
    DEALER = 'magna'
    INTERIOR_ROOT_IDS = %w[149 179 526 520 523 566 515].freeze

    private

    def each_item(&)
      doc.css('offer').each(&)
    end

    def map_item(offer)
      category_id = text(offer, 'categoryId')
      return unless interior_category?(category_id)

      source_price = decimal(text(offer, 'price'))
      title = text(offer, 'name')

      {
        dealer: DEALER,
        external_id: offer['id'],
        slug: nil,
        title: title,
        brand: brand(offer),
        series: series_from_category(category_id),
        collection: offer['group_id'],
        variant_group_key: variant_group_key(offer, title),
        variant_color: variant_color(offer),
        material: material(offer),
        finish: finish(offer),
        glass: param(offer, 'Стекло'),
        height_mm: number_from_text(param(offer, 'Высота полотна')),
        width_mm: number_from_text(param(offer, 'Ширина полотна')),
        thickness_mm: number_from_text(param(offer, 'Толщина полотна')),
        price: source_price,
        source_price: source_price,
        old_price: decimal(text(offer, 'oldprice')),
        currency: text(offer, 'currencyId') || 'BYN',
        image_url: text(offer, 'picture'),
        image_thumbnail_url: text(offer, 'picture'),
        image_medium_url: text(offer, 'picture'),
        image_original_url: text(offer, 'picture'),
        source_url: text(offer, 'url'),
        description: clean_html(text(offer, 'description')),
        available: offer['available'] == 'true',
        active: true,
        raw_data: raw_data(offer),
        door_model: door_model(title)
      }
    end

    def interior_category?(category_id)
      path_ids(category_id).intersect?(INTERIOR_ROOT_IDS)
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

    def series_from_category(category_id)
      category_name(category_id)
    end

    def brand(offer)
      param(offer, 'Производитель') || text(offer, 'vendor')
    end

    def variant_group_key(offer, title)
      if offer['group_id'].present?
        "#{DEALER}-#{offer['group_id']}"
      else
        "#{DEALER}-#{door_model(title).parameterize}"
      end
    end

    def variant_color(offer)
      param(offer, 'Цвет (Межкомнатные двери)') ||
        param(offer, 'Цвет') ||
        extract_color_from_url(text(offer, 'url'))
    end

    def extract_color_from_url(url)
      return if url.blank?

      url[/attribute_pa_czvet-mezhkomnatnye-dveri=([^&]+)/, 1]
        &.tr('-', ' ')
        &.squish
    end

    def material(offer)
      param(offer, 'Материал')
    end

    def finish(offer)
      param(offer, 'Покрытие') || category_name(text(offer, 'categoryId'))
    end

    def number_from_text(value)
      value.to_s[/\d+/]&.to_i
    end

    def raw_data(offer)
      {
        group_id: offer['group_id'],
        category_id: text(offer, 'categoryId'),
        vendor_code: text(offer, 'vendorCode'),
        params: offer.css('param').to_h { |node| [node['name'], node.text.strip] }
      }
    end

    def door_model(title)
      title.to_s
           .sub(/\Aмежкомнатная дверь\s+/i, '')
           .delete('"')
           .squish
    end
  end
end
