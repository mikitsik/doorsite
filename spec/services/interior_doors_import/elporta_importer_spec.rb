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

        <products>
          <product>
            <id>6507</id>
            <title>Legno 39</title>
            <url>https://elporta.by/legno-39-milk-oak</url>
            <category_id>89</category_id>
            <price>76.38</price>
            <color_id>20</color_id>
            <glass_id>5</glass_id>
            <pictures>
              <picture>
                <thumbnail>https://example.com/thumb.jpg</thumbnail>
                <medium>https://example.com/medium.jpg</medium>
                <original>https://example.com/original.jpg</original>
              </picture>
            </pictures>
          </product>

          <product>
            <id>6508</id>
            <title>Legno 39</title>
            <url>https://elporta.by/legno-39-thermo-oak</url>
            <category_id>89</category_id>
            <price>80.00</price>
            <color_id>21</color_id>
          </product>

          <product>
            <id>9000</id>
            <title>Porta R</title>
            <category_id>62</category_id>
            <price>500.00</price>
          </product>
        </products>

        <propertyValues>
          <propertyValue>
            <product_id>6507</product_id>
            <title>Описание</title>
            <value><![CDATA[<p>Описание двери Legno</p>]]></value>
          </propertyValue>
        </propertyValues>
      </catalog>
    XML
  end

  before do
    File.write(file_path, xml)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  it 'imports only interior doors and resolves color, glass and images' do
    count = described_class.new(file_path: file_path).call

    expect(count).to eq(2)
    expect(InteriorDoor.count).to eq(2)

    first = InteriorDoor.find_by!(external_id: '6507')

    expect(first.dealer).to eq('elporta')
    expect(first.variant_group_key).to eq('elporta:89:legno-39')
    expect(first.variant_color).to eq('Milk Oak')
    expect(first.glass).to eq('Magic Fog')
    expect(first.image_url).to eq('https://example.com/original.jpg')
    expect(first.description).to eq('Описание двери Legno')
  end
end
