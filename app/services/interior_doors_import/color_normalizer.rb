# frozen_string_literal: true

module InteriorDoorsImport
  class ColorNormalizer
    UNKNOWN_TONE = 'unknown'

    RULES = {
      'light' => [
        'white', 'snow', 'bianco', 'ivory', 'super white', 'ash white',
        'alaska', 'milk', 'vanilla', 'vanil',
        'бел', 'сноу', 'айвори', 'ваниль', 'белен'
      ],
      'gray' => %w[
        grey gray grigio nardo грей сер
      ],
      'dark' => %w[
        black wenge dark graphite onyx
        черн венге антрацит графит
      ],
      'warm' => %w[
        cappuccino latte brown
        капучино кофе коричнев
      ],
      'wood' => [
        'oak', 'дуб', 'орех', 'anegri', 'natur',
        'real oak', 'organic oak', 'nordic oak', 'thermo oak'
      ],
      'metallic' => %w[
        хром никель бронз золото серебро
        chrome gold silver metal металл
      ]
    }.freeze

    def self.call(value)
      new(value).call
    end

    def initialize(value)
      @value = value.to_s.downcase.strip
    end

    def call
      return UNKNOWN_TONE if @value.blank?

      matched_rule&.first || UNKNOWN_TONE
    end

    private

    def matched_rule
      RULES.find do |_tone, keywords|
        keywords.any? { |keyword| @value.include?(keyword) }
      end
    end
  end
end
