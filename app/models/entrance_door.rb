# frozen_string_literal: true

class EntranceDoor < ApplicationRecord
  DEALERS = %w[magna elporta].freeze

  before_validation :normalize_dealer
  before_validation :generate_slug, if: -> { slug.blank? }

  before_save :build_searchable_text

  validates :dealer, presence: true, inclusion: { in: DEALERS }
  validates :external_id, presence: true
  validates :title, presence: true
  validates :dealer, uniqueness: { scope: :external_id }
  validates :slug, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :available, -> { where(available: true) }

  def to_param
    slug
  end

  private

  def normalize_dealer
    self.dealer = dealer.to_s.downcase.presence
  end

  def build_searchable_text
    self.searchable_text = [
      title,
      brand,
      series,
      collection,
      use_case,
      construction_type,
      outer_color,
      inner_color,
      material,
      filling,
      glass,
      country_of_origin,
      description
    ].compact_blank.join(' ').downcase
  end

  def generate_slug
    base =
      series.presence ||
      title.presence ||
      brand.presence ||
      'vhodnaya-dver'

    normalized_base = base.parameterize.presence || 'vhodnaya-dver'

    self.slug = [
      normalized_base,
      external_id
    ].join('-')
  end
end
