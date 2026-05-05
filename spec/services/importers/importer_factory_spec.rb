# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::ImporterFactory do
  let(:file_path) { Rails.root.join('tmp/test_factory_import.xml') }

  after do
    FileUtils.rm_f(file_path)
  end

  describe '.build' do
    it 'returns YML importer for yml_catalog XML' do
      source = create(:product_source, source_type: 'xml')

      File.write(file_path, <<~XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <yml_catalog>
          <shop>
            <offers></offers>
          </shop>
        </yml_catalog>
      XML

      importer = described_class.build(product_source: source, file_path: file_path)

      expect(importer).to be_a(Importers::Xml::YmlImporter)
    end

    it 'returns Elporta importer for Elporta catalog XML' do
      source = create(:product_source, source_type: 'xml')

      File.write(file_path, <<~XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <catalog>
          <products>
            <product>
              <id>1</id>
            </product>
          </products>
        </catalog>
      XML

      importer = described_class.build(product_source: source, file_path: file_path)

      expect(importer).to be_a(Importers::Xml::ElportaImporter)
    end

    it 'raises for unknown XML format' do
      source = create(:product_source, source_type: 'xml')

      File.write(file_path, <<~XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <unknown></unknown>
      XML

      expect do
        described_class.build(product_source: source, file_path: file_path)
      end.to raise_error(ArgumentError, 'Unknown XML format')
    end

    it 'raises for future CSV importer' do
      source = create(:product_source, source_type: 'csv')

      expect do
        described_class.build(product_source: source, file_path: file_path)
      end.to raise_error(NotImplementedError, 'CSV importer is not implemented')
    end

    it 'raises for unsupported source_type' do
      source = create(:product_source, source_type: 'xlsx')

      expect do
        described_class.build(product_source: source, file_path: file_path)
      end.to raise_error(ArgumentError, 'Unsupported source_type: xlsx')
    end
  end
end
