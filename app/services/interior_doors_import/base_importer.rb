# frozen_string_literal: true

require 'nokogiri'

module InteriorDoorsImport
  class BaseImporter
    def initialize(file_path:)
      @file_path = file_path
      @doc = Nokogiri::XML(File.read(file_path))
    end

    def call
      imported = 0

      each_item do |item|
        attrs = map_item(item)
        next if attrs.blank?

        door = InteriorDoor.find_or_initialize_by(
          dealer: attrs[:dealer],
          external_id: attrs[:external_id]
        )

        door.update!(attrs)
        imported += 1
      end

      imported
    end

    private

    attr_reader :doc

    def text(node, selector)
      return if node.blank?

      node.at_css(selector)&.text&.strip
    end

    def decimal(value)
      return if value.blank?

      BigDecimal(value.to_s.tr(',', '.'))
    end

    def param(node, name)
      node.css('param').find { |param_node| param_node['name'] == name }&.text&.strip
    end

    def clean_html(value)
      return if value.blank?

      Nokogiri::HTML.fragment(value).text.squish
    end
  end
end
