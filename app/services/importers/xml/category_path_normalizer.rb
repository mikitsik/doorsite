# frozen_string_literal: true

module Importers
  module Xml
    module CategoryPathNormalizer
      private

      def normalized_category_path(path, catalog_section = nil)
        section = catalog_section.presence || inferred_catalog_section(path)

        root = {
          source: 'internal',
          source_category_id: "#{section}-root",
          title: normalized_root_title(section),
          position: nil
        }

        tail = Array(path).reject do |item|
          item[:title].to_s == root[:title]
        end

        [root, *tail]
      end

      def category_path_text(path)
        Array(path).pluck(:title).compact.join(' ').squish
      end

      def inferred_catalog_section(path)
        text = category_path_text(path)

        return map_catalog_section(text) if respond_to?(:map_catalog_section, true)

        downcased = text.downcase

        return 'hardware' if downcased.match?(/фурнитур|ручк|замок|защёл|защел|петл|цилиндр/)
        return 'systems' if downcased.match?(/раздвиж|складн|скрыт|портал/)
        return 'entrance' if downcased.match?(/входн|металлическ|термо|уличн|квартирн/)
        return 'interior' if downcased.match?(/межкомнат|экошпон|эко шпон|эмаль|шпон|массив/)

        'systems'
      end

      def normalized_root_title(section)
        return catalog_section_title(section) if respond_to?(:catalog_section_title, true)

        {
          'entrance' => 'Входные двери',
          'interior' => 'Межкомнатные двери',
          'systems' => 'Дверные системы',
          'hardware' => 'Фурнитура'
        }.fetch(section, 'Дверные системы')
      end
    end
  end
end
