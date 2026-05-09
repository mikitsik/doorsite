# frozen_string_literal: true

require 'nokogiri'

module EntranceDoorsImport
  class BaseImporter
    def initialize(file_path:)
      @file_path = file_path
    end

    def call
      raise NotImplementedError
    end

    private

    attr_reader :file_path

    def doc
      @doc ||= Nokogiri::XML(File.read(file_path)) { |config| config.strict.noblanks }
    end

    def text(node, selector)
      node.at_css(selector)&.text&.strip.presence
    end

    def decimal(value)
      return if value.blank?

      BigDecimal(value.to_s.tr(',', '.'))
    rescue ArgumentError
      nil
    end

    def integer_from(value)
      source = value.to_s.downcase

      return 1 if source.match?(/\b(один|одно|одна)\b/)
      return 2 if source.match?(/\b(два|две)\b/)
      return 3 if source.match?(/\bтри\b/)
      return 4 if source.match?(/\bчетыре\b/)
      return 5 if source.match?(/\bпять\b/)

      source[/\d+/]&.to_i
    end

    # rubocop:disable Naming/PredicateMethod
    def parse_boolean(value)
      %w[true 1 yes да].include?(value.to_s.downcase)
    end
    # rubocop:enable Naming/PredicateMethod

    def clean_html(value)
      return if value.blank?

      Nokogiri::HTML.fragment(value).text.squish
    end

    def upsert_entrance_door!(attrs)
      record = EntranceDoor.find_or_initialize_by(
        dealer: attrs.fetch(:dealer),
        external_id: attrs.fetch(:external_id)
      )

      record.update!(attrs)
      record
    end
  end
end
