# frozen_string_literal: true

module InteriorDoorsImport
  module Elporta
    module CategoryResolver
      INTERIOR_ROOT_ID = '42'

      INTERIOR_SERIES_TITLES = [
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
      ].freeze

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
        path_ids(category_id).filter_map { |id| category_name(id) }
      end

      def series_name(category_id)
        path_titles(category_id).find { |title| interior_series_title?(title) }
      end

      def material(product)
        value_from_description_blocks(product, ['Материал'])
      end

      def interior_series_title?(title)
        INTERIOR_SERIES_TITLES.any? do |keyword|
          title.to_s.downcase.include?(keyword.downcase)
        end
      end
    end
  end
end
