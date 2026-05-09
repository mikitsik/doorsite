# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntranceDoor do
  describe 'validations' do
    it 'requires dealer, external_id and title' do
      door = described_class.new

      expect(door).not_to be_valid
      expect(door.errors[:dealer]).to be_present
      expect(door.errors[:external_id]).to be_present
      expect(door.errors[:title]).to be_present
    end

    it 'normalizes dealer before validation' do
      door = described_class.new(
        dealer: 'Elporta',
        external_id: '3839',
        title: 'Porta R 104.П28'
      )

      expect(door).to be_valid
      expect(door.dealer).to eq('elporta')
    end

    it 'requires unique external_id inside dealer' do
      described_class.create!(
        dealer: 'elporta',
        external_id: '3839',
        title: 'Porta R 104.П28'
      )

      duplicate = described_class.new(
        dealer: 'elporta',
        external_id: '3839',
        title: 'Porta R 104.П28'
      )

      expect(duplicate).not_to be_valid
    end
  end

  describe 'searchable_text' do
    it 'builds searchable text from important fields' do
      door = described_class.create!(
        dealer: 'magna',
        external_id: '28999',
        title: 'ПРОМЕТ Винтер',
        brand: 'Промет',
        series: 'Винтер',
        category: 'Входные двери',
        outer_color: 'Серый',
        inner_color: 'Белый',
        material: 'Металл / МДФ'
      )

      expect(door.searchable_text).to include('промет')
      expect(door.searchable_text).to include('винтер')
      expect(door.searchable_text).to include('серый')
      expect(door.searchable_text).to include('металл / мдф')
    end
  end
end
