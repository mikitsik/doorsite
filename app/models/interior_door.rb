# frozen_string_literal: true

class InteriorDoor < ApplicationRecord
  DEALERS = %w[magna elporta].freeze

  before_validation :normalize_dealer
  before_validation :generate_slug, if: -> { slug.blank? }
  before_validation :build_model_group_key
  before_save :build_searchable_text

  validates :dealer, presence: true, inclusion: { in: DEALERS }
  validates :external_id, :source_title, :door_model, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :external_id, uniqueness: { scope: :dealer }

  def to_param
    slug
  end

  def display_title
    [door_model, vendor_color].compact_blank.join(' · ')
  end

  def seo_title
    ['Межкомнатная дверь', brand, door_model, vendor_color, '— ДВЕРНОЙ.БЕЛ'].compact_blank.join(' ')
  end

  private

  def normalize_dealer
    self.dealer = dealer.to_s.downcase.presence
  end

  def generate_slug
    base = [brand, series, door_model, vendor_color].compact_blank.join(' ')
    normalized_base = slugify(base).presence || 'mezhkomnatnaya-dver'

    self.slug = [normalized_base, external_id].join('-')
  end

  def slugify(value)
    value.to_s.to_slug.normalize(transliterations: :russian).to_s
  end

  def build_searchable_text
    self.searchable_text = [
      'межкомнатная дверь',
      'межкомнатные двери',

      source_title,
      brand,
      dealer,
      series,
      door_model,
      vendor_color,
      hint_tone,
      material,
      glass,
      description
    ].compact_blank.join(' ').squish.downcase
  end

  def build_model_group_key
    self.model_group_key = [
      dealer,
      door_model
    ].compact_blank.map { |part| part.to_s.parameterize }.join('-')
  end
end
