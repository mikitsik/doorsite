# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::ImporterFactory do
  describe 'XML importers' do
    describe 'YML / Magna format' do
      let(:source) { create(:product_source, name: 'Magna XML', source_type: 'xml') }
      let(:file_path) { Rails.root.join('tmp/test_magna.xml') }

      before do
        FileUtils.mkdir_p(Rails.root.join('tmp'))

        File.write(file_path, <<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <yml_catalog>
            <shop>
              <categories>
                <category id="109">Входные металлические двери</category>
              </categories>
              <offers>
                <offer id="m-1" available="true">
                  <name>Дверь Магна 1</name>
                  <price>744.90</price>
                  <currencyId>BYN</currencyId>
                  <categoryId>109</categoryId>
                  <picture>https://example.com/magna.jpg</picture>
                  <url>https://example.com/magna-1</url>
                  <description>Описание Magna</description>
                  <vendorCode>MG-1</vendorCode>
                </offer>
              </offers>
            </shop>
          </yml_catalog>
        XML
      end

      after do
        FileUtils.rm_f(file_path)
      end

      it 'imports YML offers' do
        batch = described_class.build(
          product_source: source,
          file_path: file_path
        ).call

        expect(batch.status).to eq('done')
        expect(batch.imported_count).to eq(1)
        expect(batch.failed_count).to eq(0)

        product = Product.find_by!(external_id: 'm-1', product_source: source)
        expect(product.title).to eq('Дверь Магна 1')
        expect(product.category).to eq('Входные металлические двери')
        expect(product.price.to_s).to eq('744.9')
        expect(product.image_url).to eq('https://example.com/magna.jpg')
        expect(product.vendor_code).to eq('MG-1')
      end
    end

    describe 'Elporta XML format' do
      let(:source) { create(:product_source, name: 'Elporta XML', source_type: 'xml') }
      let(:file_path) { Rails.root.join('tmp/test_elporta.xml') }

      before do
        FileUtils.mkdir_p(Rails.root.join('tmp'))

        File.write(file_path, <<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <catalog>
            <products>
              <product>
                <id>6507</id>
                <title>Ручка K.EST.Q52.MEGA</title>
                <url>https://elporta.by/product-6507</url>
                <category_id>486</category_id>
                <price>76.38</price>
                <pictures>
                  <picture>
                    <thumbnail>https://example.com/thumb.jpg</thumbnail>
                    <medium>https://example.com/medium.jpg</medium>
                    <original>https://example.com/original.jpg</original>
                  </picture>
                </pictures>
              </product>
            </products>
          </catalog>
        XML
      end

      after do
        FileUtils.rm_f(file_path)
      end

      it 'imports Elporta products' do
        batch = described_class.build(
          product_source: source,
          file_path: file_path
        ).call

        expect(batch.status).to eq('done')
        expect(batch.imported_count).to eq(1)
        expect(batch.failed_count).to eq(0)

        product = Product.find_by!(external_id: '6507', product_source: source)
        expect(product.title).to eq('Ручка K.EST.Q52.MEGA')
        expect(product.brand).to eq('Elporta')
        expect(product.category).to eq('Двери')
        expect(product.price.to_s).to eq('76.38')
        expect(product.image_url).to eq('https://example.com/original.jpg')
        expect(product.raw_data).to include('id' => '6507')
      end
    end
  end
end
