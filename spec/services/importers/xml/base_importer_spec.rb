# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Xml::BaseImporter do
  describe 'mapped data validation' do
    let(:product_source) do
      ProductSource.create!(
        name: 'Test XML',
        source_type: 'xml',
        url: 'tmp/imports/test.xml',
        enabled: true,
        sync_strategy: 'manual',
        settings: {}
      )
    end

    let(:file_path) { Rails.root.join('tmp/imports/test.xml').to_s }

    let(:importer_class) do
      Class.new(described_class) do
        private

        def each_item
          [:item]
        end

        def map_item(_item)
          {
            external_id: '1',
            title: 'Test door',
            category: 'Межкомнатные двери',
            source_category_id: '42',
            source_category_path: [{ title: 'Межкомнатные двери' }]
          }
        end
      end
    end

    it 'does not import product when catalog_section is missing' do
      importer_class.new(product_source:, file_path:).call

      batch = ImportBatch.last

      expect(Product.count).to eq(0)
      expect(batch.imported_count).to eq(0)
      expect(batch.failed_count).to eq(1)
      expect(batch.error_message).to be_nil
    end
  end
end
