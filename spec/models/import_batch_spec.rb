# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportBatch, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:product_source) }
    it { is_expected.to have_many(:products).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }

    it 'allows known statuses' do
      expect(build(:import_batch, status: 'pending')).to be_valid
      expect(build(:import_batch, status: 'processing')).to be_valid
      expect(build(:import_batch, status: 'done')).to be_valid
      expect(build(:import_batch, status: 'failed')).to be_valid
    end

    it 'rejects unknown status' do
      expect(build(:import_batch, status: 'bad')).not_to be_valid
    end
  end
end
