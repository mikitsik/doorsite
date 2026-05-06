# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Xml::CatalogClassifier do
  subject(:classifier) do
    Class.new do
      include Importers::Xml::CatalogClassifier

      public :map_door_type_from
      public :map_category_from
    end.new
  end

  describe '#map_door_type_from' do
    it 'classifies entrance doors' do
      expect(classifier.map_door_type_from('Входные двери с терморазрывом')).to eq('entrance')
      expect(classifier.map_door_type_from('Porta R-2 металл-мдф')).to eq('entrance')
    end

    it 'classifies interior doors' do
      expect(classifier.map_door_type_from('Межкомнатные двери Эко Шпон')).to eq('interior')
      expect(classifier.map_door_type_from('Эмаль Classico')).to eq('interior')
    end

    it 'classifies hardware' do
      expect(classifier.map_door_type_from('Фурнитура ручки петли')).to eq('hardware')
      expect(classifier.map_door_type_from('Цилиндры и замки')).to eq('hardware')
    end

    it 'classifies everything else as systems' do
      expect(classifier.map_door_type_from('Раздвижные двери')).to eq('systems')
      expect(classifier.map_door_type_from('Скрытые двери')).to eq('systems')
      expect(classifier.map_door_type_from('Порталы')).to eq('systems')
    end
  end

  describe '#map_category_from' do
    it 'maps door type to display category' do
      expect(classifier.map_category_from('entrance')).to eq('Входные двери')
      expect(classifier.map_category_from('interior')).to eq('Межкомнатные двери')
      expect(classifier.map_category_from('systems')).to eq('Дверные системы')
      expect(classifier.map_category_from('hardware')).to eq('Фурнитура')
    end
  end
end
