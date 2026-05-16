# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InteriorDoor do
  describe 'validations' do
    it 'requires core fields' do
      door = described_class.new

      expect(door).not_to be_valid
      expect(door.errors[:dealer]).to be_present
      expect(door.errors[:external_id]).to be_present
      expect(door.errors[:title]).to be_present
      expect(door.errors[:variant_group_key]).to be_present
    end

    it 'requires unique external_id per dealer' do
      described_class.create!(
        dealer: 'magna',
        external_id: '100',
        title: 'Door',
        door_model: 'Door',
        variant_group_key: 'magna:10'
      )

      duplicate = described_class.new(
        dealer: 'magna',
        external_id: '100',
        title: 'Door copy',
        variant_group_key: 'magna:10'
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:external_id]).to be_present
    end
  end

  describe '#to_param' do
    it 'returns slug' do
      door = described_class.new(slug: 'interior-door-test')

      expect(door.to_param).to eq('interior-door-test')
    end
  end

  describe 'callbacks' do
    it 'generates slug and searchable_text' do
      door = described_class.create!(
        dealer: 'magna',
        external_id: '101',
        title: 'Межкомнатная дверь Test',
        door_model: 'Test',
        brand: 'Юни',
        variant_color: 'Эмаль белая',
        variant_group_key: 'magna:101'
      )

      expect(door.slug).to be_present
      expect(door.searchable_text).to include('межкомнатная дверь test')
      expect(door.searchable_text).to include('эмаль белая')
    end
  end
end
