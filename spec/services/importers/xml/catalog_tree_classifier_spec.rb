# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Xml::CatalogTreeClassifier do
  subject(:classifier) { test_class.new }

  let(:test_class) do
    Class.new do
      include Importers::Xml::CatalogTreeClassifier

      def section(text)
        map_catalog_section(text)
      end

      def title(section)
        catalog_section_title(section)
      end
    end
  end

  it 'detects entrance doors' do
    expect(classifier.section('Входные двери с терморазрывом')).to eq('entrance')
  end

  it 'detects Elporta entrance collections before hardware' do
    expect(classifier.section('Входные двери Porta S-2P (металл-мдф)')).to eq('entrance')
  end

  it 'prefers explicit interior category paths over Elporta entrance series markers' do
    expect(classifier.section('Межкомнатные двери Porta S-2P')).to eq('interior')
  end

  it 'detects interior doors' do
    expect(classifier.section('Межкомнатные двери с эмалью')).to eq('interior')
  end

  it 'detects hardware' do
    expect(classifier.section('Фурнитура Ручки дверные')).to eq('hardware')
  end

  it 'prefers explicit hardware category paths over Elporta entrance series markers' do
    expect(classifier.section('Фурнитура Porta S замки')).to eq('hardware')
  end

  it 'does not classify by hardware words outside an explicit hardware category' do
    text = 'Входные двери Porta S-2P (металл-мдф) ручки замки петли'

    expect(classifier.section(text)).to eq('entrance')
  end

  it 'detects systems' do
    expect(classifier.section('Раздвижные системы')).to eq('systems')
  end

  it 'returns section title' do
    expect(classifier.title('interior')).to eq('Межкомнатные двери')
  end
end
