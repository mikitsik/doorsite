# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogCategory do
  describe 'associations' do
    it 'supports parent and children tree' do
      parent = described_class.create!(
        slug: 'interior',
        title: 'Межкомнатные двери',
        kind: 'interior',
        source: 'internal',
        source_category_id: 'interior-root'
      )

      child = described_class.create!(
        slug: 'interior-enamel',
        title: 'Межкомнатные двери с эмалью',
        kind: 'interior',
        source: 'magna',
        source_category_id: '850',
        parent: parent
      )

      expect(parent.children).to include(child)
      expect(child.parent).to eq(parent)
    end
  end

  describe '#to_param' do
    it 'returns slug' do
      category = described_class.new(slug: 'entrance-doors')

      expect(category.to_param).to eq('entrance-doors')
    end
  end
end
