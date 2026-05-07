# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Xml::YmlImporter do
  let(:product_source) do
    ProductSource.create!(
      name: 'Magna XML',
      source_type: 'yml',
      url: 'tmp/imports/magna.xml',
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )
  end

  let(:file_path) do
    Rails.root.join('tmp/imports/test_magna.yml.xml')
  end

  before do
    FileUtils.mkdir_p(file_path.dirname)

    File.write(file_path, <<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <yml_catalog>
        <shop>
          <categories>
            <category id="149">Межкомнатные двери</category>
            <category id="850" parentId="149">Межкомнатные двери с эмалью</category>
          </categories>
          <offers>
            <offer id="30490" group_id="30489" available="true">
              <currencyId>BYN</currencyId>
              <price>381.61</price>
              <oldprice>439.32</oldprice>
              <param name="Производитель">Юни</param>
              <param name="Назначение двери">Межкомнатная дверь</param>
              <param name="Стекло">Без стекла</param>
              <param name="Цвет (Межкомнатные двери)">Эмаль белая</param>
              <name>Межкомнатная дверь ЭМАЛЬ ЛАЙН 08</name>
              <description><![CDATA[<p>Описание товара</p>]]></description>
              <picture>https://example.com/door.jpg</picture>
              <url>https://example.com/product</url>
              <country_of_origin>Беларусь</country_of_origin>
              <vendor>Юни</vendor>
              <vendorCode>001949-0</vendorCode>
              <categoryId>850</categoryId>
            </offer>
          </offers>
        </shop>
      </yml_catalog>
    XML
  end

  after do
    FileUtils.rm_f(file_path)
  end

  it 'imports product with catalog category tree' do
    described_class.new(product_source:, file_path: file_path.to_s).call

    product = Product.find_by!(external_id: '30490', product_source:)

    expect(product.title).to eq('Межкомнатная дверь ЭМАЛЬ ЛАЙН 08')
    expect(product.brand).to eq('Юни')
    expect(product.dealer).to eq('Magna')
    expect(product.catalog_section).to eq('interior')
    expect(product.category).to eq('Межкомнатные двери')
    expect(product.source_category_id).to eq('850')
    expect(product.source_category_title).to eq('Межкомнатные двери с эмалью')
    expect(product.source_category_path.pluck('title')).to include(
      'Межкомнатные двери',
      'Межкомнатные двери с эмалью'
    )
    expect(product.catalog_category).to be_present
    expect(product.catalog_category.title).to eq('Межкомнатные двери с эмалью')
  end

  it 'creates import batch counters' do
    batch = described_class.new(product_source:, file_path: file_path.to_s).call

    expect(batch.status).to eq('done')
    expect(batch.imported_count).to eq(1)
    expect(batch.updated_count).to eq(0)
    expect(batch.failed_count).to eq(0)
  end
end
