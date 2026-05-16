# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InteriorDoor do
  describe 'validations' do
    it 'requires core fields' do
      door = described_class.new

      expect(door).not_to be_valid
      expect(door.errors[:dealer]).to be_present
      expect(door.errors[:external_id]).to be_present
      expect(door.errors[:source_title]).to be_present
      expect(door.errors[:door_model]).to be_present
    end

    it 'requires unique external_id per dealer' do
      described_class.create!(
        dealer: 'magna',
        external_id: '100',
        source_title: 'Door',
        door_model: 'Door'
      )

      duplicate = described_class.new(
        dealer: 'magna',
        external_id: '100',
        source_title: 'Door copy',
        door_model: 'Door copy'
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
    it 'generates slug, model_group_key and searchable_text' do
      door = described_class.create!(
        dealer: 'magna',
        external_id: '101',
        source_title: 'Межкомнатная дверь Test',
        door_model: 'Test',
        brand: 'Юни',
        vendor_color: 'Эмаль белая'
      )

      expect(door.slug).to be_present
      expect(door.model_group_key).to eq('magna-test')
      expect(door.searchable_text).to include('межкомнатная дверь')
      expect(door.searchable_text).to include('эмаль белая')
    end
  end
end
