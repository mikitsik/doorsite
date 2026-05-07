# frozen_string_literal: true

module Importers
  module Xml
    class YmlImporter < BaseImporter
      include CatalogTreeClassifier
      include CategoryPathNormalizer

      DEALER = 'Magna'
      CATALOG_SOURCE = 'magna'

      private

      def each_item
        doc.css('offer')
      end

      def map_item(offer)
        category_id = text(offer, 'categoryId')
        category_path = category_path(category_id)
        source_category = category_path.last&.dig(:title)
        catalog_section = catalog_section_for(offer, category_path)

        source_price = decimal(text(offer, 'price'))
        old_price = decimal(text(offer, 'oldprice'))

        base_product_data(offer, catalog_section).merge(
          catalog_data(category_id, category_path, source_category, catalog_section),
          price_data(source_price, old_price),
          detail_data(offer),
          import_data(offer, source_category)
        )
      end

      def base_product_data(offer, catalog_section)
        {
          external_id: offer['id'],
          slug: build_slug(offer),
          title: text(offer, 'name'),
          brand: brand(offer),
          dealer: DEALER,
          door_type: catalog_section,
          category: catalog_section_title(catalog_section),
          collection: offer['group_id']
        }
      end

      def catalog_data(category_id, category_path, source_category, catalog_section)
        {
          catalog_source: CATALOG_SOURCE,
          catalog_section: catalog_section,
          source_category: source_category,
          source_category_id: category_id,
          source_category_title: source_category,
          source_category_path: category_path
        }
      end

      def price_data(source_price, old_price)
        {
          source_price: source_price,
          price: source_price,
          old_price: old_price,
          discount: calculate_discount(source_price, old_price),
          currency: 'BYN'
        }
      end

      def detail_data(offer)
        {
          image_url: text(offer, 'picture'),
          source_url: text(offer, 'url'),
          description: clean_description(text(offer, 'description')),
          vendor_code: text(offer, 'vendorCode'),
          color: normalize_color(color(offer)),
          material: material(offer),
          finish: finish(offer),
          glass: param(offer, 'Стекло'),
          country_of_origin: param(offer, 'Страна производитель') || text(offer, 'country_of_origin')
        }
      end

      def import_data(offer, source_category)
        {
          available: offer['available'] == 'true',
          active: true,
          raw_data: raw_data(offer),
          searchable_text: searchable_text(offer, source_category)
        }
      end

      def catalog_section_for(offer, category_path)
        source = [
          param(offer, 'Назначение двери'),
          text(offer, 'name'),
          category_path.pluck(:title).join(' ')
        ].compact.join(' ').downcase

        map_catalog_section(source)
      end

      def categories
        @categories ||= doc.css('category').each_with_object({}) do |category, hash|
          id = category['id'].to_s

          hash[id] = {
            id: id,
            title: category.text.to_s.squish,
            parent_id: category['parentId'].presence&.to_s,
            position: 0
          }
        end
      end

      def category_path(category_id)
        path = []
        current = categories[category_id.to_s]

        while current.present?
          path.unshift(
            id: current[:id],
            title: current[:title],
            position: current[:position]
          )

          current = categories[current[:parent_id].to_s]
        end

        normalized_category_path(path)
      end

      def build_slug(offer)
        [
          DEALER,
          offer['id'],
          text(offer, 'name')
        ].compact.join(' ')
      end

      def brand(offer)
        param(offer, 'Производитель') ||
          text(offer, 'vendor') ||
          DEALER
      end

      def color(offer)
        param(offer, 'Цвет (Межкомнатные двери)') ||
          param(offer, 'Цвет снаружи') ||
          param(offer, 'Цвет внутри') ||
          param(offer, 'Цвет')
      end

      def material(offer)
        param(offer, 'Материал') ||
          param(offer, 'Материал двери') ||
          param(offer, 'Материал полотна') ||
          param(offer, 'Наполнение двери')
      end

      def finish(offer)
        param(offer, 'Покрытие') ||
          param(offer, 'Отделка снаружи') ||
          param(offer, 'Отделка внутри')
      end

      def param(offer, name)
        offer.css('param').find { |param_node| param_node['name'] == name }&.text.to_s.squish.presence
      end

      def normalize_color(value)
        value.to_s.squish.presence
      end

      def calculate_discount(source_price, old_price)
        return nil if source_price.blank? || old_price.blank? || old_price.zero?

        (((old_price - source_price) / old_price) * 100).round
      end

      def clean_description(value)
        value.to_s.gsub(/<[^>]*>/, ' ').squish.presence
      end

      def raw_data(offer)
        {
          attributes: offer.attributes.transform_values(&:value),
          fields: children_to_hash(offer),
          params: offer.css('param').to_h do |param_node|
                    [param_node['name'], param_node.text.to_s.squish]
                  end
        }
      end

      def searchable_text(offer, source_category)
        [
          text(offer, 'name'),
          brand(offer),
          source_category,
          param(offer, 'Производитель'),
          param(offer, 'Назначение двери'),
          param(offer, 'Стекло'),
          color(offer),
          material(offer),
          finish(offer),
          text(offer, 'vendorCode')
        ].compact.join(' ').downcase.squish
      end
    end
  end
end
