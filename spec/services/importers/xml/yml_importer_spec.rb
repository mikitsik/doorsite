# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe Importers::Xml::YmlImporter do
  let(:product_source) do
    ProductSource.create!(
      name: 'Magna XML',
      source_type: 'yml',
      url: 'https://example.com/magna.xml',
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )
  end

  let(:file_path) { Rails.root.join('tmp/spec_magna.xml') }

  let(:xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <yml_catalog>
        <shop>
          <categories>
            <category id="850" parentId="149">Межкомнатные двери с эмалью</category>
          </categories>
          <offers>
            <offer id="30490" group_id="30489" available="true">
              <currencyId>BYN</currencyId>
              <price>381.61</price>
              <oldprice>439.32</oldprice>
              <param name="Производитель">Юни</param>
              <param name="Страна производитель">Беларусь</param>
              <param name="Назначение двери">Межкомнатная дверь</param>
              <param name="Стекло">Без стекла</param>
              <param name="Цвет (Межкомнатные двери)">Эмаль белая</param>
              <param name="Материал">Массив сосны</param>
              <param name="Покрытие">Эмаль</param>
              <name>Межкомнатная дверь ЭМАЛЬ ЛАЙН 08</name>
              <description><![CDATA[<p>Описание двери</p>]]></description>
              <picture>https://example.com/door.jpg</picture>
              <url>https://example.com/product/door</url>
              <vendor>Юни</vendor>
              <vendorCode>001949-0</vendorCode>
              <categoryId>850</categoryId>
            </offer>
          </offers>
        </shop>
      </yml_catalog>
    XML
  end

  before do
    File.write(file_path, xml)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#call' do
    it 'imports Magna YML offer into normalized Product' do
      expect do
        described_class.new(product_source:, file_path: file_path.to_s).call
      end.to change(Product, :count).by(1)
                                    .and change(ImportBatch, :count).by(1)

      product = Product.find_by!(external_id: '30490', product_source:)

      expect(product.title).to eq('Межкомнатная дверь ЭМАЛЬ ЛАЙН 08')
      expect(product.brand).to eq('Юни')
      expect(product.dealer).to eq('Magna')
      expect(product.door_type).to eq('interior')
      expect(product.category).to eq('Межкомнатные двери')
      expect(product.collection).to eq('30489')
      expect(product.source_category).to eq('Межкомнатные двери с эмалью')
      expect(product.source_category_id).to eq('850')
      expect(product.source_price).to eq(BigDecimal('381.61'))
      expect(product.price).to eq(BigDecimal('381.61'))
      expect(product.old_price).to eq(BigDecimal('439.32'))
      expect(product.discount).to eq(BigDecimal('13.14'))
      expect(product.currency).to eq('BYN')
      expect(product.color).to eq('белая')
      expect(product.material).to eq('Массив сосны')
      expect(product.finish).to eq('Эмаль')
      expect(product.glass).to eq('Без стекла')
      expect(product.country_of_origin).to eq('Беларусь')
      expect(product.vendor_code).to eq('001949-0')
      expect(product.image_url).to eq('https://example.com/door.jpg')
      expect(product.source_url).to eq('https://example.com/product/door')
      expect(product.available).to be(true)
      expect(product.active).to be(true)
      expect(product.raw_data['params']['Производитель']).to eq('Юни')
      expect(product.searchable_text).to include('юни', 'межкомнатные двери', '001949-0')
    end

    it 'updates existing product on repeated import' do
      importer = described_class.new(product_source:, file_path: file_path.to_s)

      expect { importer.call }.to change(Product, :count).by(1)
      expect { importer.call }.not_to change(Product, :count)

      product = Product.find_by!(external_id: '30490', product_source:)
      expect(product.import_batch).to be_present
      expect(product_source.reload.last_synced_at).to be_present
    end
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
