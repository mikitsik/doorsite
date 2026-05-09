# frozen_string_literal: true

class EntranceDoor < ApplicationRecord
  DEALERS = %w[magna elporta].freeze

  before_validation :normalize_dealer
  before_save :build_searchable_text

  validates :dealer, presence: true, inclusion: { in: DEALERS }
  validates :external_id, presence: true
  validates :title, presence: true
  validates :dealer, uniqueness: { scope: :external_id }

  scope :active, -> { where(active: true) }
  scope :available, -> { where(available: true) }

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
      category,
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
end
