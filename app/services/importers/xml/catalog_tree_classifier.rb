# frozen_string_literal: true

module Importers
  module Xml
    module CatalogTreeClassifier
      ENTRANCE_CATEGORY_PATTERN = /\A\s*входные двери\b/u
      INTERIOR_CATEGORY_PATTERN = /\A\s*межкомнатные двери\b/u
      SYSTEMS_CATEGORY_PATTERN = /\A\s*дверные системы\b/u
      HARDWARE_CATEGORY_PATTERNS = %w[фурнитура ручки замки защелки защёлки петли цилиндры накладки фиксаторы
                                      ограничители глазки]
                                   .map do |keyword|
        /\A\s*#{Regexp.escape(keyword)}\b/u
      end.freeze
      SYSTEMS_KEYWORDS = %w[раздвиж складн скрыт портал].freeze
      ENTRANCE_CONTEXT_KEYWORDS = %w[входн металлическ терморазрыв термо уличн квартирн промет магнабел металл-мдф
                                     мдф-мдф].freeze
      ENTRANCE_PORTA_SERIES = ['porta r', 'porta s', 'porta m', 'porta t'].freeze
      INTERIOR_KEYWORDS = ['межкомнат', 'эко шпон', 'экошпон', 'эмаль', 'полипропилен', 'эксимер', 'винил', 'массив',
                           'шпон', 'флекс', 'cpl', 'эмалит', 'ламинац', 'porta c', 'porta x', 'porta z', 'classico',
                           'neoclassico', 'vetro', 'simple', 'bravo', 'moda', 'prima', 'legno', 'olovi', 'оливи'].freeze

      private

      def map_catalog_section(source)
        text = source.to_s.downcase

        section = explicit_category_section(text)
        return section if section

        return 'entrance' if entrance?(text)
        return 'interior' if interior?(text)
        return 'systems' if systems?(text)
        return 'hardware' if hardware?(text)

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

      def explicit_category_section(text)
        return 'entrance' if text.match?(ENTRANCE_CATEGORY_PATTERN)
        return 'interior' if text.match?(INTERIOR_CATEGORY_PATTERN)
        return 'systems' if text.match?(SYSTEMS_CATEGORY_PATTERN)

        'hardware' if hardware?(text)
      end

      def hardware?(text)
        HARDWARE_CATEGORY_PATTERNS.any? { |pattern| text.match?(pattern) }
      end

      def systems?(text)
        text.include?('дверные системы') || SYSTEMS_KEYWORDS.any? { |keyword| text.include?(keyword) }
      end

      def entrance?(text)
        return true if entrance_context?(text)
        return false unless ambiguous_category_path?(text)

        ENTRANCE_PORTA_SERIES.any? { |keyword| text.include?(keyword) }
      end

      def entrance_context?(text)
        ENTRANCE_CONTEXT_KEYWORDS.any? { |keyword| text.include?(keyword) }
      end

      def ambiguous_category_path?(text)
        !text.match?(INTERIOR_CATEGORY_PATTERN) &&
          !text.match?(SYSTEMS_CATEGORY_PATTERN) &&
          !hardware?(text)
      end

      def interior?(text)
        INTERIOR_KEYWORDS.any? { |keyword| text.include?(keyword) }
      end
    end
  end
end
