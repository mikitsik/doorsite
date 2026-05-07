# frozen_string_literal: true

module Importers
  module Xml
    module CatalogTreeClassifier
      private

      def map_catalog_section(source)
        return 'entrance' if entrance?(source)
        return 'interior' if interior?(source)
        return 'hardware' if hardware?(source)
        return 'systems' if systems?(source)

        'systems'
      end

      def catalog_section_title(section)
        {
          'entrance' => 'Входные двери',
          'interior' => 'Межкомнатные двери',
          'systems' => 'Дверные системы',
          'hardware' => 'Фурнитура'
        }.fetch(section, 'Другое')
      end

      def entrance?(source)
        %w[
          входн
          металлическ
          терморазрыв
          термо
          уличн
          квартирн
          промет
          магнабел
          металл-мдф
          мдф-мдф
        ].any? { |keyword| source.include?(keyword) }
      end

      def interior?(source)
        [
          'межкомнат',
          'эко шпон',
          'экошпон',
          'эмаль',
          'пвх',
          'ламинац',
          'olovi',
          'оливи',
          'амати',
          'бона',
          'флэш',
          'стандарт',
          'перфето',
          'финские'
        ].any? { |keyword| source.include?(keyword) }
      end

      def systems?(source)
        %w[
          раздвиж
          складн
          скрыт
          портал
          система
        ].any? { |keyword| source.include?(keyword) }
      end

      def hardware?(source)
        %w[
          фурнитур
          ручк
          замк
          защёлк
          защелк
          петл
          цилиндр
          накладк
          фиксатор
          шпингалет
          упор
          глазк
        ].any? { |keyword| source.include?(keyword) }
      end
    end
  end
end
