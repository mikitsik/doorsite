# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Xml::CategoryPathNormalizer do
  subject(:normalizer) { test_class.new }

  let(:test_class) do
    Class.new do
      include Importers::Xml::CategoryPathNormalizer

      def call(path)
        normalized_category_path(path)
      end
    end
  end

  it 'adds entrance root' do
    path = [
      { id: '586', title: 'Металлические входные двери', position: 0 },
      { id: '853', title: 'Входные двери с терморазрывом', position: 0 }
    ]

    result = normalizer.call(path)

    expect(result.first).to include(id: 'entrance-root', title: 'Входные двери')
    expect(result.last).to include(id: '853')
  end

  it 'adds interior root' do
    path = [
      { id: '850', title: 'Межкомнатные двери с эмалью', position: 0 }
    ]

    result = normalizer.call(path)

    expect(result.first).to include(id: 'interior-root', title: 'Межкомнатные двери')
  end

  it 'does not duplicate existing root' do
    path = [
      { id: 'interior-root', title: 'Межкомнатные двери', position: 0 },
      { id: '850', title: 'Межкомнатные двери с эмалью', position: 0 }
    ]

    result = normalizer.call(path)

    expect(result.count { |node| node[:title] == 'Межкомнатные двери' }).to eq(1)
  end
end
