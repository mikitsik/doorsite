# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe Importers::Xml::ElportaImporter do
  let(:product_source) do
    ProductSource.create!(
      name: 'Elporta XML',
      source_type: 'xml',
      url: 'https://example.com/elporta.xml',
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )
  end

  let(:file_path) { Rails.root.join('tmp/spec_elporta.xml') }

  let(:xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <catalog>
        <categories>
          <category>
            <id>42</id>
            <title>Межкомнатные двери</title>
            <position>35</position>
          </category>
          <category>
            <id>70</id>
            <title>Эко Шпон</title>
            <parent_id>42</parent_id>
            <position>36</position>
          </category>
        </categories>

        <colors>
          <color>
            <id>20</id>
            <title>Milk Oak</title>
            <picture>https://example.com/colors/milk-oak.jpg</picture>
          </color>
        </colors>

        <glasses>
          <color>
            <id>1</id>
            <title>Без стекла</title>
          </color>
        </glasses>

        <properties>
          <property>
            <id>10</id>
            <title>Материал</title>
          </property>
          <property>
            <id>11</id>
            <title>Покрытие</title>
          </property>
        </properties>

        <propertyValues>
          <propertyValue>
            <id>100</id>
            <property_id>10</property_id>
            <title>МДФ</title>
          </propertyValue>
          <propertyValue>
            <id>101</id>
            <property_id>11</property_id>
            <title>Эко Шпон</title>
          </propertyValue>
        </propertyValues>

        <products>
          <product>
            <id>6507</id>
            <title>Legno 39 Milk Oak</title>
            <url>https://elporta.by/catalog/legno-39-milk-oak</url>
            <category_id>70</category_id>
            <color_id>20</color_id>
            <glass_id>1</glass_id>
            <price>245.50</price>
            <old_price>300.00</old_price>
            <discount>18.17</discount>
            <label>sale</label>

            <pictures>
              <picture>
                <thumbnail>https://example.com/thumb.jpg</thumbnail>
                <medium>https://example.com/medium.jpg</medium>
                <original>https://example.com/original.jpg</original>
              </picture>
            </pictures>

            <propertyValues>
              <propertyValue>
                <id>100</id>
              </propertyValue>
              <propertyValue>
                <id>101</id>
              </propertyValue>
            </propertyValues>
          </product>
        </products>
      </catalog>
    XML
  end

  before do
    File.write(file_path, xml)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#call' do
    it 'imports Elporta product into normalized Product' do
      expect do
        described_class.new(product_source:, file_path: file_path.to_s).call
      end.to change(Product, :count).by(1)
                                    .and change(ImportBatch, :count).by(1)

      product = Product.find_by!(external_id: '6507', product_source:)

      expect(product.title).to eq('Legno 39 Milk Oak')
      expect(product.brand).to eq('Elporta')
      expect(product.dealer).to eq('Elporta')
      expect(product.door_type).to eq('interior')
      expect(product.category).to eq('Межкомнатные двери')
      expect(product.collection).to eq('Эко Шпон')
      expect(product.source_category).to eq('Эко Шпон')
      expect(product.source_category_id).to eq('70')
      expect(product.source_price).to eq(BigDecimal('245.50'))
      expect(product.price).to eq(BigDecimal('245.50'))
      expect(product.old_price).to eq(BigDecimal('300.00'))
      expect(product.discount).to eq(BigDecimal('18.17'))
      expect(product.currency).to eq('BYN')
      expect(product.color).to eq('Milk Oak')
      expect(product.material).to eq('МДФ')
      expect(product.finish).to eq('Эко Шпон')
      expect(product.glass).to eq('Без стекла')
      expect(product.country_of_origin).to eq('Беларусь')
      expect(product.image_url).to eq('https://example.com/original.jpg')
      expect(product.source_url).to eq('https://elporta.by/catalog/legno-39-milk-oak')
      expect(product.available).to be(true)
      expect(product.active).to be(true)
      expect(product.raw_data['color_name']).to eq('Milk Oak')
      expect(product.raw_data['glass_name']).to eq('Без стекла')
      expect(product.raw_data['properties']).to include(
        { 'property' => 'Материал', 'value' => 'МДФ' },
        { 'property' => 'Покрытие', 'value' => 'Эко Шпон' }
      ).or include(
        { property: 'Материал', value: 'МДФ' },
        { property: 'Покрытие', value: 'Эко Шпон' }
      )
      expect(product.searchable_text).to include('legno', 'elporta', 'milk oak', 'мдф')
    end

    it 'updates existing product on repeated import' do
      importer = described_class.new(product_source:, file_path: file_path.to_s)

      expect { importer.call }.to change(Product, :count).by(1)
      expect { importer.call }.not_to change(Product, :count)

      product = Product.find_by!(external_id: '6507', product_source:)
      expect(product.import_batch).to be_present
      expect(product_source.reload.last_synced_at).to be_present
    end
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
