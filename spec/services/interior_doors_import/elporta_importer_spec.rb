# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InteriorDoorsImport::ElportaImporter do
  let(:file_path) { Rails.root.join('tmp/spec_elporta_interior.xml') }

  let(:xml) do
    <<~XML
      <catalog>
        <categories>
          <category>
            <id>42</id>
            <title>Межкомнатные двери</title>
          </category>
          <category>
            <id>70</id>
            <title>Эко Шпон</title>
            <parent_id>42</parent_id>
          </category>
          <category>
            <id>89</id>
            <title>Legno</title>
            <parent_id>70</parent_id>
          </category>
          <category>
            <id>62</id>
            <title>Входные двери</title>
          </category>
        </categories>

        <colors>
          <color>
            <id>20</id>
            <title>Milk Oak</title>
          </color>
          <color>
            <id>21</id>
            <title>Thermo Oak</title>
          </color>
        </colors>

        <glasses>
          <glass>
            <id>5</id>
            <title>Magic Fog</title>
          </glass>
        </glasses>

        <properties>
          <property>
            <id>61</id>
            <title>Описание</title>
          </property>
          <property>
            <id>16</id>
            <title>Материал</title>
          </property>
          <property>
            <id>11</id>
            <title>Отделка</title>
          </property>
          <property>
            <id>25</id>
            <title>Толщина, мм</title>
          </property>
        </properties>

        <propertyValues>
          <propertyValue>
            <id>1001</id>
            <property_id>61</property_id>
            <title>Описание двери Legno</title>
          </propertyValue>
          <propertyValue>
            <id>1002</id>
            <property_id>16</property_id>
            <title>МДФ + массив сосны</title>
          </propertyValue>
          <propertyValue>
            <id>1003</id>
            <property_id>11</property_id>
            <title>Эко Шпон</title>
          </propertyValue>
          <propertyValue>
            <id>1004</id>
            <property_id>25</property_id>
            <title>36</title>
          </propertyValue>
        </propertyValues>

        <products>
          <product>
            <id>6507</id>
            <title>Legno 39</title>
            <url>https://elporta.by/legno-39-milk-oak</url>
            <category_id>89</category_id>
            <price>76.38</price>
            <old_price>90.00</old_price>
            <color_id>20</color_id>
            <glass_id>5</glass_id>

            <pictures>
              <picture>
                <thumbnail>https://example.com/thumb.jpg</thumbnail>
                <medium>https://example.com/medium.jpg</medium>
                <original>https://example.com/original.jpg</original>
              </picture>
            </pictures>

            <options>
              <option>
                <title>200*60</title>
              </option>
            </options>

            <propertyValues>
              <propertyValue>
                <id>1001</id>
              </propertyValue>
              <propertyValue>
                <id>1002</id>
              </propertyValue>
              <propertyValue>
                <id>1003</id>
              </propertyValue>
              <propertyValue>
                <id>1004</id>
              </propertyValue>
            </propertyValues>
          </product>

          <product>
            <id>6508</id>
            <title>Legno 39</title>
            <url>https://elporta.by/legno-39-thermo-oak</url>
            <category_id>89</category_id>
            <price>80.00</price>
            <color_id>21</color_id>

            <propertyValues>
              <propertyValue>
                <id>1001</id>
              </propertyValue>
            </propertyValues>
          </product>

          <product>
            <id>9000</id>
            <title>Porta R</title>
            <category_id>62</category_id>
            <price>500.00</price>
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

  def import!
    described_class.new(file_path: file_path).call
  end

  def first_door
    InteriorDoor.find_by!(external_id: '6507')
  end

  it 'imports only interior doors' do
    count = import!

    expect(count).to eq(2)
    expect(InteriorDoor.count).to eq(2)
  end

  it 'resolves main product fields' do
    import!

    expect(first_door.dealer).to eq('elporta')
    expect(first_door.variant_group_key).to eq('elporta:89:legno-39')
    expect(first_door.variant_color).to eq('Milk Oak')
    expect(first_door.glass).to eq('Magic Fog')
    expect(first_door.image_url).to eq('https://example.com/original.jpg')
  end

  it 'resolves dimensions and commercial fields' do
    import!

    expect(first_door.height_mm).to eq(2000)
    expect(first_door.width_mm).to eq(600)
    expect(first_door.thickness_mm).to eq(36)
    expect(first_door.price.to_f).to eq(76.38)
    expect(first_door.old_price.to_f).to eq(90.0)
  end

  it 'resolves properties and description blocks' do
    import!

    expect(first_door.description).to eq('Описание двери Legno МДФ + массив сосны Эко Шпон')
    expect(first_door.material).to eq('МДФ + массив сосны')
    expect(first_door.finish).to eq('Эко Шпон')
    expect(first_door.raw_data['description_blocks']).to include('Описание двери Legno')
  end

  it 'stores normalized raw properties' do
    import!

    expect(first_door.raw_data['properties']).to include(
      {
        'property_id' => '61',
        'property' => 'Описание',
        'title' => 'Описание двери Legno'
      }
    )
  end
end
