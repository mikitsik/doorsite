# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InteriorDoorsImport::MagnaImporter do
  let(:file_path) { Rails.root.join('tmp/spec_magna_interior.xml') }

  let(:xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <yml_catalog>
        <shop>
          <categories>
            <category id="149">Межкомнатные двери</category>
            <category id="850" parentId="149">Межкомнатные двери с эмалью</category>
            <category id="586">Металлические входные двери</category>
          </categories>
          <offers>
            <offer id="30490" group_id="30489" available="true">
              <price>381.61</price>
              <currencyId>BYN</currencyId>
              <param name="Производитель">Юни</param>
              <param name="Назначение двери">Межкомнатная дверь</param>
              <param name="Стекло">Без стекла</param>
              <param name="Цвет (Межкомнатные двери)">Эмаль белая</param>
              <name>Межкомнатная дверь ЭМАЛЬ ЛАЙН 08</name>
              <picture>https://example.com/white.jpg</picture>
              <url>https://example.com/white</url>
              <vendorCode>001949-0</vendorCode>
              <categoryId>850</categoryId>
            </offer>

            <offer id="30491" group_id="30489" available="true">
              <price>439.32</price>
              <currencyId>BYN</currencyId>
              <param name="Производитель">Юни</param>
              <param name="Цвет (Межкомнатные двери)">Эмаль графит</param>
              <name>Межкомнатная дверь ЭМАЛЬ ЛАЙН 08</name>
              <picture>https://example.com/graphite.jpg</picture>
              <url>https://example.com/graphite</url>
              <categoryId>850</categoryId>
            </offer>

            <offer id="50000" available="true">
              <price>1000</price>
              <name>Входная дверь</name>
              <categoryId>586</categoryId>
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

  it 'imports only interior doors and groups color variants' do
    count = described_class.new(file_path: file_path).call

    expect(count).to eq(2)
    expect(InteriorDoor.count).to eq(2)
    expect(InteriorDoor.pluck(:external_id)).to contain_exactly('30490', '30491')

    expect(
      InteriorDoor.distinct.pluck(:model_group_key)
    ).to eq(['magna-emal-lain-08'])

    expect(
      InteriorDoor.pluck(:vendor_color)
    ).to contain_exactly('Эмаль белая', 'Эмаль графит')

    expect(InteriorDoor.first.door_model).to eq('ЭМАЛЬ ЛАЙН 08')
  end
end
