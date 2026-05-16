# frozen_string_literal: true

require_relative 'color_normalizer'

module InteriorDoorsImport
  class MagnaImporter < BaseImporter
    DEALER = 'magna'

    INTERIOR_ROOT_IDS = %w[
      149
      179
      526
      520
      523
      566
      515
    ].freeze

    SKIP_CATEGORY_KEYWORDS = [
      'уценка',
      'распродажа',
      'фурнитура',
      'ручки',
      'петли',
      'замки',
      'защёлки',
      'защелки',
      'погонаж',
      'доборы',
      'наличники',
      'притворные планки'
    ].freeze

    private

    def each_item(&)
      doc.css('offer').each(&)
    end

    def map_item(offer)
      category_id = text(offer, 'categoryId')
      return unless interior_category?(category_id)
      return if skipped_category?(category_id)
      return if offer['available'] == 'false'

      source_title = text(offer, 'name')
      vendor_color = vendor_color(offer)

      {
        dealer: DEALER,
        external_id: offer['id'],
        slug: nil,
        source_title: source_title,
        brand: brand(offer),
        series: series_from_category(category_id),
        door_model: door_model(source_title),
        vendor_color: vendor_color,
        hint_tone: ColorNormalizer.call(vendor_color),
        material: material(offer),
        glass: param(offer, 'Стекло'),
        height_mm: number_from_text(param(offer, 'Высота полотна')),
        width_mm: number_from_text(param(offer, 'Ширина полотна')),
        thickness_mm: number_from_text(param(offer, 'Толщина полотна')),
        source_price: decimal(text(offer, 'price')),
        image_url: text(offer, 'picture'),
        image_thumbnail_url: text(offer, 'picture'),
        image_medium_url: text(offer, 'picture'),
        image_original_url: text(offer, 'picture'),
        source_url: text(offer, 'url'),
        description: clean_html(text(offer, 'description')),
        raw_data: raw_data(offer, category_id)
      }
    end

    def interior_category?(category_id)
      path_ids(category_id).intersect?(INTERIOR_ROOT_IDS)
    end

    def skipped_category?(category_id)
      path_titles(category_id).any? do |title|
        SKIP_CATEGORY_KEYWORDS.any? { |keyword| title.to_s.downcase.include?(keyword) }
      end
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

    def path_titles(category_id)
      path_ids(category_id).reverse.filter_map { |id| category_name(id) }
    end

    def brand(offer)
      param(offer, 'Производитель') || text(offer, 'vendor')
    end

    def series_from_category(category_id)
      titles = path_titles(category_id).join(' ').downcase

      return 'Эмаль' if titles.include?('эмаль')
      return 'Эко Шпон' if titles.include?('экошпон') || titles.include?('эко шпон')
      return 'ПВХ' if titles.include?('пвх')
      return 'Ламинация' if titles.include?('ламинац')
      return 'Натуральный шпон' if titles.include?('натуральный шпон')
      return 'Шпон' if titles.include?('шпон')

      category_name(category_id)
    end

    def door_model(source_title)
      title = source_title.to_s
                          .sub(/\Aмежкомнатная дверь\s+/i, '')
                          .delete('"')
                          .delete('«')
                          .delete('»')
                          .sub(/\(.+\)\z/, '')
                          .squish

      quoted = quoted_series(source_title)
      return title if quoted.blank?

      suffix = title.sub(quoted, '').squish

      if quoted.casecmp('ЭМАЛЬ ЛАЙН').zero?
        "ЛАЙН #{suffix}".squish
      elsif quoted.casecmp('ЭМАЛЬ').zero?
        suffix.presence || quoted
      else
        [quoted, suffix].compact_blank.join(' ')
      end
    end

    def quoted_series(source_title)
      source_title.to_s[/["«]([^"»]+)["»]/, 1]
    end

    def vendor_color(offer)
      param(offer, 'Цвет (Межкомнатные двери)') ||
        param(offer, 'Цвет') ||
        color_from_url(text(offer, 'url'))
    end

    def color_from_url(url)
      return if url.blank?

      url[/attribute_pa_czvet-mezhkomnatnye-dveri=([^&]+)/, 1]
        &.tr('-', ' ')
        &.squish
    end

    def material(offer)
      param(offer, 'Материал')
    end

    def number_from_text(value)
      value.to_s[/\d+/]&.to_i
    end

    def raw_data(offer, category_id)
      {
        source_group_id: offer['group_id'],
        category_id: category_id,
        category_path: path_titles(category_id),
        vendor_code: text(offer, 'vendorCode'),
        currency: text(offer, 'currencyId'),
        available: offer['available'],
        params: offer.css('param').to_h { |node| [node['name'], node.text.strip] }
      }
    end
  end
end
