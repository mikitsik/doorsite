# frozen_string_literal: true

module CatalogImport
  module CategoryRoots
    module ElportaRoots
      ROOT_CATEGORIES = {
        '62' => {
          catalog_type: :entrance_door,
          source_title: 'Входные двери'
        }.freeze,
        '42' => {
          catalog_type: :interior_door,
          source_title: 'Межкомнатные двери'
        }.freeze,
        '59' => {
          catalog_type: :door_system,
          source_title: 'Раздвижные двери'
        }.freeze,
        '61' => {
          catalog_type: :door_system,
          source_title: 'Складные двери'
        }.freeze,
        '579' => {
          catalog_type: :door_system,
          source_title: 'Скрытые двери'
        }.freeze,
        '63' => {
          catalog_type: :door_system,
          source_title: 'Порталы'
        }.freeze,
        '65' => {
          catalog_type: :furniture,
          source_title: 'Фурнитура'
        }.freeze,
        '347' => {
          catalog_type: :baseboard,
          source_title: 'Плинтус'
        }.freeze,
        '605' => {
          catalog_type: :decorative_slats,
          source_title: 'Рейки декортивные'
        }.freeze,
        '66' => {
          catalog_type: :installation,
          source_title: 'Монтаж и реставрация'
        }.freeze
      }.freeze
    end
  end
end
