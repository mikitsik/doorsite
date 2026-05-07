# frozen_string_literal: true

module Importers
  module Xml
    module CategoryPathNormalizer
      private

      def normalized_category_path(path)
        return path if path.blank?

        titles = path_titles(path)

        return normalized_path(path, 'entrance-root', 'Входные двери') if entrance_path?(titles)
        return normalized_path(path, 'interior-root', 'Межкомнатные двери') if interior_path?(titles)
        return normalized_path(path, 'systems-root', 'Дверные системы') if systems_path?(titles)
        return normalized_path(path, 'hardware-root', 'Фурнитура') if hardware_path?(titles)

        path
      end

      def path_titles(path)
        path.pluck(:title).join(' ').downcase
      end

      def entrance_path?(titles)
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
        ].any? { |keyword| titles.include?(keyword) }
      end

      def interior_path?(titles)
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
        ].any? { |keyword| titles.include?(keyword) }
      end

      def systems_path?(titles)
        %w[
          раздвиж
          складн
          скрыт
          портал
          система
        ].any? { |keyword| titles.include?(keyword) }
      end

      def hardware_path?(titles)
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
        ].any? { |keyword| titles.include?(keyword) }
      end

      def normalized_path(path, root_id, root_title)
        return path if path.first[:title] == root_title

        [
          {
            id: root_id,
            title: root_title,
            position: 0
          },
          *path
        ]
      end
    end
  end
end
