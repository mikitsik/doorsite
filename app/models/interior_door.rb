# frozen_string_literal: true

class InteriorDoor < ApplicationRecord
  DEALERS = %w[magna elporta].freeze

  before_validation :normalize_dealer
  before_validation :generate_slug, if: -> { slug.blank? }

  before_save :build_searchable_text

  validates :dealer, presence: true, inclusion: { in: DEALERS }
  validates :external_id, presence: true
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :dealer, uniqueness: { scope: :external_id }

  scope :active, -> { where(active: true) }
  scope :available, -> { where(available: true) }

  def to_param
    slug
  end

  private

  def normalize_dealer
    self.dealer = dealer.to_s.downcase.presence
  end

  def generate_slug
    base =
      series.presence ||
      title.presence ||
      brand.presence ||
      'mezhkomnatnaya-dver'

    normalized_base = base.parameterize.presence || 'mezhkomnatnaya-dver'

    self.slug = [
      normalized_base,
      external_id
    ].join('-')
  end

  def build_searchable_text
    self.searchable_text = [
      title,
      brand,
      series,
      collection,
      variant_color,
      material,
      finish,
      glass,
      description
    ].compact_blank.join(' ').squish.downcase
  end
end
