# frozen_string_literal: true

module InteriorDoorsImport
  module Elporta
    module CategoryResolver
      INTERIOR_ROOT_ID = '42'

      private

      def interior_category?(category_id)
        path_ids(category_id).include?(INTERIOR_ROOT_ID)
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
        path_ids(category_id).map { |id| category_name(id) }.compact
      end

      def top_series(category_id)
        path = path_ids(category_id)
        return if path.length < 2

        category_name(path.first)
      end

      def material(category_id, product)
        value_from_description_blocks(product, ['Материал']) ||
          path_titles(category_id).find do |title|
            interior_material_title?(title)
          end
      end

      def finish(category_id, product)
        value_from_description_blocks(product, %w[Покрытие Отделка]) || material(category_id, product)
      end

      def interior_material_title?(title)
        [
          'Эко Шпон',
          'Полипропилен',
          'Эксимер',
          'Флекс Эмаль',
          'Массив',
          'Винил',
          'Хард Флекс',
          'Эмалит',
          'CPL',
          'Финиш Флекс',
          'Шпон'
        ].any? { |keyword| title.include?(keyword) }
      end
    end
  end
end
