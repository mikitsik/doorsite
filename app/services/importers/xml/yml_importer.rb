# frozen_string_literal: true

module Importers
  module Xml
    class YmlImporter < BaseImporter
      include CatalogClassifier

      DEALER = 'Magna'

      private

      def each_item
        doc.css('offer')
      end

      def map_item(offer)
        category_id = text(offer, 'categoryId')
        source_category = category_name(category_id)

        source_price = decimal(text(offer, 'price'))
        old_price = decimal(text(offer, 'oldprice'))

        {
          external_id: offer['id'],
          slug: build_slug(offer),
          title: text(offer, 'name'),
          brand: brand(offer),
          dealer: DEALER,
          door_type: map_door_type(offer, source_category),
          category: map_category(offer, source_category),
          collection: offer['group_id'],
          source_price: source_price,
          price: source_price,
          old_price: old_price,
          discount: calculate_discount(source_price, old_price),
          currency: text(offer, 'currencyId') || 'BYN',
          image_url: text(offer, 'picture'),
          source_url: text(offer, 'url'),
          description: clean_description(text(offer, 'description')),
          vendor_code: text(offer, 'vendorCode'),
          color: normalize_color(color(offer)),
          material: material(offer),
          finish: finish(offer),
          glass: param(offer, 'Стекло'),
          country_of_origin: param(offer, 'Страна производитель') || text(offer, 'country_of_origin'),
          source_category: source_category,
          source_category_id: category_id,
          available: offer['available'] == 'true',
          active: true,
          raw_data: raw_data(offer),
          searchable_text: searchable_text(offer, source_category)
        }
      end

      def categories
        @categories ||= doc.css('category').to_h do |category|
          [category['id'].to_s, category.text.to_s.squish]
        end
      end

      def category_name(category_id)
        categories[category_id.to_s]
      end

      def brand(offer)
        param(offer, 'Производитель') || text(offer, 'vendor') || DEALER
      end

      def color(offer)
        param(offer, 'Цвет (Межкомнатные двери)') ||
          param(offer, 'Цвет') ||
          param(offer, 'Цвет снаружи') ||
          param(offer, 'Цвет внутри')
      end

      def material(offer)
        param(offer, 'Материал') ||
          param(offer, 'Наполнение двери')
      end

      def finish(offer)
        param(offer, 'Покрытие') ||
          param(offer, 'Отделка снаружи') ||
          param(offer, 'Отделка внутри')
      end

      def map_door_type(offer, source_category)
        source = [
          source_category,
          param(offer, 'Назначение двери'),
          param(offer, 'Тип'),
          param(offer, 'Тип двери'),
          text(offer, 'name')
        ].compact.join(' ')

        map_door_type_from(source)
      end

      def map_category(offer, source_category)
        map_category_from(map_door_type(offer, source_category))
      end

      def normalize_color(value)
        value.to_s
             .squish
             .sub(/\Aэмаль\s+/i, '')
             .presence
      end

      def param(offer, name)
        offer.css('param').find { |node| node['name'] == name }&.text&.squish
      end

      def text(node, selector)
        node.at_css(selector)&.text&.squish.presence
      end

      def decimal(value)
        return nil if value.blank?

        BigDecimal(value.to_s.tr(',', '.'))
      end

      def calculate_discount(price, old_price)
        return nil if price.blank? || old_price.blank? || old_price.zero?

        (((old_price - price) / old_price) * 100).round(2)
      end

      def clean_description(value)
        ActionView::Base.full_sanitizer.sanitize(value.to_s).squish.presence
      end

      def build_slug(offer)
        base = [
          DEALER,
          offer['group_id'],
          offer['id'],
          text(offer, 'name'),
          color(offer)
        ].compact.join(' ')

        base.parameterize
      end

      def raw_data(offer)
        {
          'id' => offer['id'],
          'group_id' => offer['group_id'],
          'available' => offer['available'],
          'params' => offer.css('param').to_h { |param_node| [param_node['name'], param_node.text.squish] },
          'category_id' => text(offer, 'categoryId'),
          'category_name' => category_name(text(offer, 'categoryId')),
          'vendor' => text(offer, 'vendor'),
          'vendor_code' => text(offer, 'vendorCode'),
          'url' => text(offer, 'url'),
          'picture' => text(offer, 'picture')
        }
      end

      def searchable_text(offer, source_category)
        [
          text(offer, 'name'),
          brand(offer),
          DEALER,
          source_category,
          map_category(offer, source_category),
          color(offer),
          material(offer),
          finish(offer),
          param(offer, 'Стекло'),
          text(offer, 'vendorCode')
        ].compact.join(' ').squish
      end
    end
  end
end
