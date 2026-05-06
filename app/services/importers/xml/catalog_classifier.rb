# frozen_string_literal: true

module Importers
  module Xml
    module CatalogClassifier
      private

      def map_door_type_from(text)
        source = text.to_s.downcase

        return 'entrance' if entrance_door?(source)
        return 'interior' if interior_door?(source)
        return 'hardware' if hardware?(source)

        'systems'
      end

      def map_category_from(door_type)
        {
          'entrance' => 'Входные двери',
          'interior' => 'Межкомнатные двери',
          'systems' => 'Дверные системы',
          'hardware' => 'Фурнитура'
        }.fetch(door_type, 'Другое')
      end

      def entrance_door?(source)
        %w[
          входные входн металлическ терморазрыв термо уличн квартирн
          промет магнабел металл-мдф мдф-мдф
        ].any? { |keyword| source.include?(keyword) }
      end

      def interior_door?(source)
        [
          'межкомнат', 'эко шпон', 'экошпон', 'эмаль', 'полипропилен',
          'эксимер', 'винил', 'массив', 'шпон', 'флекс', 'cpl',
          'эмалит', 'ламинац', 'porta x', 'porta z', 'classico',
          'neoclassico', 'vetro', 'simple', 'bravo', 'moda', 'prima',
          'legno', 'olovi', 'оливи'
        ].any? { |keyword| source.include?(keyword) }
      end

      def hardware?(source)
        [
          'фурнитур', 'ручк', 'замок', 'замки', 'защелк', 'защёлк',
          'петл', 'цилиндр', 'фиксатор', 'накладк', 'шпингалет',
          'засов', 'упор', 'ограничитель', 'глазок', 'порог',
          'сердцевин', 'ролик', 'направляющие', 'ручки купе'
        ].any? { |keyword| source.include?(keyword) }
      end
    end
  end
end
