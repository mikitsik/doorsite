# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:product_source).optional }
    it { is_expected.to belong_to(:import_batch).optional }
  end

  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:brand) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:currency) }
  end

  describe 'searchable_text' do
    it 'builds searchable_text before save' do
      product = create(
        :product,
        title: 'Дверь Альфа',
        brand: 'Elporta',
        category: 'Межкомнатные',
        vendor_code: 'ABC-123',
        description: 'Белая дверь'
      )

      expect(product.searchable_text).to include('дверь альфа')
      expect(product.searchable_text).to include('elporta')
      expect(product.searchable_text).to include('abc-123')
      expect(product.searchable_text).to include('белая дверь')
    end
  end

  describe '#to_param' do
    it 'returns slug' do
      product = build(:product, slug: 'door-test')
      expect(product.to_param).to eq('door-test')
    end
  end
end
