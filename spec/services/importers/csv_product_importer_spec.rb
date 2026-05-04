# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::CsvProductImporter do
  let(:source) { create(:product_source, name: 'Test CSV', source_type: 'csv') }
  let(:file_path) { Rails.root.join('tmp/test_import_products.csv') }

  before do
    FileUtils.mkdir_p(Rails.root.join('tmp'))

    File.write(file_path, <<~CSV)
      slug,title,brand,category,price,currency,image_url,description,source_url,external_id,vendor_code,active
      door-1,Дверь 1,Elporta,Межкомнатные,100,BYN,https://example.com/1.jpg,Описание 1,https://example.com/p1,ext-1,VC-1,true
      door-2,Дверь 2,Torex,Входные,200,BYN,https://example.com/2.jpg,Описание 2,https://example.com/p2,ext-2,VC-2,true
    CSV
  end

  after do
    FileUtils.rm_f(file_path)
  end

  it 'imports products from CSV' do
    batch = described_class.new(product_source: source, file_path: file_path).call

    expect(batch.status).to eq('done')
    expect(batch.imported_count).to eq(2)
    expect(batch.updated_count).to eq(0)
    expect(batch.failed_count).to eq(0)

    expect(Product.count).to eq(2)

    product = Product.find_by!(external_id: 'ext-1', product_source: source)
    expect(product.title).to eq('Дверь 1')
    expect(product.brand).to eq('Elporta')
    expect(product.price.to_s).to eq('100.0')
    expect(product.raw_data).to include('title' => 'Дверь 1')
  end

  it 'updates existing products on second import' do
    described_class.new(product_source: source, file_path: file_path).call

    batch = described_class.new(product_source: source, file_path: file_path).call

    expect(batch.imported_count).to eq(0)
    expect(batch.updated_count).to eq(2)
    expect(Product.count).to eq(2)
  end
end
