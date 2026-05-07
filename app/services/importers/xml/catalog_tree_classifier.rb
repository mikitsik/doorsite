# frozen_string_literal: true

module Importers
  module Xml
    module CatalogTreeClassifier
      private

      def map_catalog_section(source)
        text = source.to_s.downcase

        return 'hardware' if hardware?(text)
        return 'systems' if systems?(text)
        return 'entrance' if entrance?(text)
        return 'interior' if interior?(text)

        'systems'
      end

      def catalog_section_title(section)
        {
          'entrance' => 'Входные двери',
          'interior' => 'Межкомнатные двери',
          'systems' => 'Дверные системы',
          'hardware' => 'Фурнитура'
        }.fetch(section, 'Дверные системы')
      end

      def hardware?(text)
        [
          'фурнитур',
          'ручк',
          'замок',
          'замки',
          'защелк',
          'защёлк',
          'петл',
          'цилиндр',
          'фиксатор',
          'накладк',
          'шпингалет',
          'засов',
          'упор',
          'ограничитель',
          'глазок',
          'порог',
          'сердцевин',
          'ролик',
          'направляющ',
          'ручки купе'
        ].any? { |keyword| text.include?(keyword) }
      end

      def systems?(text)
        [
          'раздвиж',
          'складн',
          'скрыт',
          'портал',
          'дверные системы'
        ].any? { |keyword| text.include?(keyword) }
      end

      def entrance?(text)
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
        ].any? { |keyword| text.include?(keyword) }
      end

      def interior?(text)
        [
          'межкомнат',
          'эко шпон',
          'экошпон',
          'эмаль',
          'полипропилен',
          'эксимер',
          'винил',
          'массив',
          'шпон',
          'флекс',
          'cpl',
          'эмалит',
          'ламинац',
          'porta x',
          'porta z',
          'classico',
          'neoclassico',
          'vetro',
          'simple',
          'bravo',
          'moda',
          'prima',
          'legno',
          'olovi',
          'оливи'
        ].any? { |keyword| text.include?(keyword) }
      end
    end
  end
end
