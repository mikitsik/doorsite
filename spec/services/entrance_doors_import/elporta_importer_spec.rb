# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntranceDoorsImport::ElportaImporter do
  let(:file_path) { Rails.root.join('tmp/spec_elporta.xml') }

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
        <catalog>
          <categories>
            <category>
              <id>62</id>
              <title>Входные двери</title>
              <position>3</position>
            </category>
            <category>
              <id>552</id>
              <title>Porta R-3 (мдф-мдф)</title>
              <parent_id>62</parent_id>
              <position>10</position>
            </category>
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
              <id>531</id>
              <title>Moon Stone/Nardo Grey</title>
            </color>
          </colors>

          <glasses />

          <propertyValues>
            <propertyValue>
              <id>1001</id>
              <property_id>61</property_id>
              <title>Стальной дверной блок произведен на автоматизированных линиях.</title>
            </propertyValue>
            <propertyValue>
              <id>1002</id>
              <property_id>94</property_id>
              <title>Сертифицирован для РБ.</title>
            </propertyValue>
            <propertyValue>
              <id>1003</id>
              <property_id>49</property_id>
              <title>Три контура высококачественного EPDM-уплотнителя.</title>
            </propertyValue>
            <propertyValue>
              <id>1004</id>
              <property_id>50</property_id>
              <title>Влагостойкая теплоизоляционная плита KNAUF Therm.</title>
            </propertyValue>
            <propertyValue>
              <id>1005</id>
              <property_id>42</property_id>
              <title>80/90</title>
            </propertyValue>
            <propertyValue>
              <id>1006</id>
              <property_id>44</property_id>
              <title>1,0</title>
            </propertyValue>
            <propertyValue>
              <id>1007</id>
              <property_id>62</property_id>
              <title>Цилиндровый замок Border.</title>
            </propertyValue>
            <propertyValue>
              <id>1008</id>
              <property_id>63</property_id>
              <title>Сувальдный замок Border.</title>
            </propertyValue>
            <propertyValue>
              <id>1009</id>
              <property_id>64</property_id>
              <title>Цилиндр.</title>
            </propertyValue>
          </propertyValues>

          <accessoryGroups>
            <accessoryGroup>
              <id>955</id>
              <title>Alaska Modern Обрамление 1</title>
              <quantity>1</quantity>
            </accessoryGroup>
          </accessoryGroups>

          <products>
            <product>
              <id>5965</id>
              <title>Porta R 89.П1</title>
              <url>https://example.com/porta-r-3</url>
              <category_id>552</category_id>
              <color_id>531</color_id>
              <glass_id></glass_id>
              <price>1365.18</price>
              <old_price>1365.18</old_price>
              <pictures>
                <picture>
                  <original>https://example.com/porta.jpg</original>
                </picture>
              </pictures>
              <options>
                <option>
                  <id>10769</id>
                  <title>205*88 Левая</title>
                  <price>1365.18</price>
                  <old_price>1365.18</old_price>
                </option>
              </options>
              <propertyValues>
                <propertyValue><id>1001</id></propertyValue>
                <propertyValue><id>1002</id></propertyValue>
                <propertyValue><id>1003</id></propertyValue>
                <propertyValue><id>1004</id></propertyValue>
                <propertyValue><id>1005</id></propertyValue>
                <propertyValue><id>1006</id></propertyValue>
                <propertyValue><id>1007</id></propertyValue>
                <propertyValue><id>1008</id></propertyValue>
                <propertyValue><id>1009</id></propertyValue>
              </propertyValues>
              <accessoryGroups>
                <accessoryGroup><id>955</id></accessoryGroup>
              </accessoryGroups>
            </product>

            <product>
              <id>7000</id>
              <title>Interior Door</title>
              <category_id>70</category_id>
              <price>100</price>
            </product>
          </products>
        </catalog>
      XML
    end

    it 'imports only entrance doors' do
      described_class.new(file_path: file_path.to_s).call

      expect(EntranceDoor.count).to eq(1)
      expect(EntranceDoor.first.external_id).to eq('5965')
    end

    it 'maps main Elporta entrance door fields', :aggregate_failures do
      described_class.new(file_path: file_path.to_s).call

      door = EntranceDoor.first

      expect(door.dealer).to eq('elporta')
      expect(door.brand).to eq('Elporta')
      expect(door.series).to eq('Porta R-3 (мдф-мдф)')
      expect(door.collection).to eq('Porta R-3 (мдф-мдф)')
      expect(door.category).to eq('Входные двери')
      expect(door.use_case).to eq('Входная дверь')
      expect(door.construction_type).to eq('мдф-мдф')
      expect(door.material).to eq('МДФ / МДФ')
      expect(door.outer_color).to eq('Moon Stone/Nardo Grey')
      expect(door.inner_color).to eq('Moon Stone/Nardo Grey')
    end

    it 'maps technical Elporta entrance door fields', :aggregate_failures do
      described_class.new(file_path: file_path.to_s).call

      door = EntranceDoor.first

      expect(door.height_mm).to eq(2050)
      expect(door.width_mm).to eq(880)
      expect(door.opening_side).to eq('Левая')
      expect(door.thickness_mm).to eq(80)
      expect(door.metal_thickness_mm).to eq(1.0)
      expect(door.filling).to eq('Влагостойкая теплоизоляционная плита KNAUF Therm.')
      expect(door.locks_count).to eq(3)
      expect(door.sealing_contours_count).to eq(3)
      expect(door.price).to eq(1365.18)
      expect(door.image_url).to eq('https://example.com/porta.jpg')
    end

    it 'stores UI description blocks in raw_data' do
      described_class.new(file_path: file_path.to_s).call

      door = EntranceDoor.first

      expect(door.description).to include('Стальной дверной блок')
      expect(door.description).not_to include("\n\n")
      expect(door.raw_data['description_blocks']).to include(
        'Стальной дверной блок произведен на автоматизированных линиях.',
        'Сертифицирован для РБ.'
      )
      expect(door.raw_data['accessory_groups'].first['title']).to eq('Alaska Modern Обрамление 1')
    end
  end
end
