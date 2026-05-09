# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntranceDoorsImport::MagnaImporter do
  let(:file_path) { Rails.root.join('tmp/spec_magna.xml') }

  before do
    File.write(file_path, xml)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#call' do
    let(:xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <yml_catalog>
          <shop>
            <categories>
              <category id="586">Металлические входные двери</category>
              <category id="853" parentId="586">Входные двери с терморазрывом</category>
              <category id="149">Межкомнатные двери</category>
              <category id="850" parentId="149">Межкомнатные двери с эмалью</category>
            </categories>
            <offers>
              <offer id="28999" group_id="28998" available="true">
                <currencyId>BYN</currencyId>
                <price>2297.10</price>
                <oldprice>2499.00</oldprice>
                <param name="Производитель">Промет</param>
                <param name="Назначение двери">Терморазрыв</param>
                <param name="Наполнение двери">Пенополистирол</param>
                <param name="Отделка снаружи">Металл с декоративным штампом</param>
                <param name="Отделка внутри">МДФ панель</param>
                <param name="Цвет снаружи">Серый</param>
                <param name="Цвет внутри">Белый</param>
                <param name="Высота (монтажный габарит)">2050 мм</param>
                <param name="Ширина (монтажный габарит)">880 мм</param>
                <param name="Толщина полотна">110 мм</param>
                <param name="Толщина металла">1.4 мм</param>
                <param name="Кол-во контуров уплотнения">4 контура</param>
                <param name="Направление открывания двери">Наружное</param>
                <param name="Сторона открывания двери">Левая</param>
                <param name="Кол-во замков">3</param>
                <param name="Страна производитель">Россия</param>
                <param name="Гарантийный срок">84 мес.</param>
                <name>ПРОМЕТ "Винтер" Панорама ТЕРМОРАЗРЫВ</name>
                <description><![CDATA[<p>Описание двери</p>]]></description>
                <picture>https://example.com/door.jpg</picture>
                <url>https://example.com/door</url>
                <vendor>Промет</vendor>
                <vendorCode>001948-0</vendorCode>
                <categoryId>853</categoryId>
              </offer>

              <offer id="30490" available="true">
                <price>381.61</price>
                <param name="Производитель">Юни</param>
                <name>Межкомнатная дверь</name>
                <categoryId>850</categoryId>
              </offer>
            </offers>
          </shop>
        </yml_catalog>
      XML
    end

    it 'imports only entrance doors' do
      described_class.new(file_path: file_path.to_s).call

      expect(EntranceDoor.count).to eq(1)
      expect(EntranceDoor.first.external_id).to eq('28999')
    end

    it 'maps Magna entrance door fields', :aggregate_failures do
      described_class.new(file_path: file_path.to_s).call

      door = EntranceDoor.first

      expect(door.dealer).to eq('magna')
      expect(door.brand).to eq('Промет')
      expect(door.series).to eq('Винтер')
      expect(door.category).to eq('Входные двери с терморазрывом')
      expect(door.use_case).to eq('Терморазрыв')
      expect(door.thermal_break).to be(true)
      expect(door.outer_color).to eq('Серый')
      expect(door.inner_color).to eq('Белый')
      expect(door.height_mm).to eq(2050)
      expect(door.width_mm).to eq(880)
      expect(door.thickness_mm).to eq(110)
      expect(door.metal_thickness_mm).to eq(1.4)
      expect(door.locks_count).to eq(3)
      expect(door.sealing_contours_count).to eq(4)
      expect(door.price).to eq(2297.10)
      expect(door.raw_data['root_category_id']).to eq('586')
    end
  end
end
