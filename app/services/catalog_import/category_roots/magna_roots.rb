# frozen_string_literal: true

module CatalogImport
  module CategoryRoots
    module MagnaRoots
      ROOT_CATEGORIES = {
        '586' => {
          catalog_type: :entrance_door,
          source_title: 'Металлические входные двери'
        }.freeze,
        '149' => {
          catalog_type: :interior_door,
          source_title: 'Межкомнатные двери'
        }.freeze,
        '768' => {
          catalog_type: :furniture,
          source_title: 'Фурнитура для межкомнатных дверей'
        }.freeze,
        '255' => {
          catalog_type: :furniture,
          source_title: 'Фурнитура для металлических дверей'
        }.freeze,
        '98' => {
          catalog_type: :entrance_door,
          source_title: 'Входные двери "МАГНА"'
        }.freeze,
        '83' => {
          catalog_type: :sale,
          source_title: '(%) Уценка'
        }.freeze,
        '93' => {
          catalog_type: :sale,
          source_title: '(%) Распродажа прошлых сезонов'
        }.freeze,
        '486' => {
          catalog_type: :furniture,
          source_title: 'Защёлки; замки'
        }.freeze,
        '179' => {
          catalog_type: :interior_door,
          source_title: 'Межкомнатные двери "OLOVI" (РФ)'
        }.freeze,
        '526' => {
          catalog_type: :interior_door,
          source_title: 'Серия "ALBICO Mikheev" (РФ) Экошпон с 3D'
        }.freeze,
        '520' => {
          catalog_type: :interior_door,
          source_title: 'Серия "КЛАССИК" (РБ) Ламинация'
        }.freeze,
        '523' => {
          catalog_type: :interior_door,
          source_title: 'Серия "ТРАДИЦИЯ" (РБ) Натуральный шпон'
        }.freeze,
        '566' => {
          catalog_type: :interior_door,
          source_title: 'Серия "ФЛЕКС" (РБ) Экошпон'
        }.freeze,
        '515' => {
          catalog_type: :interior_door,
          source_title: 'Серия "ЭЛЛЕТИ" (РБ) Экошпон'
        }.freeze
      }.freeze
    end
  end
end
