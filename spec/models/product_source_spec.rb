# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductSource, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:import_batches).dependent(:destroy) }
    it { is_expected.to have_many(:products).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:source_type) }
    it { is_expected.to validate_presence_of(:sync_strategy) }
  end
end
