# frozen_string_literal: true

class Product < ApplicationRecord
  before_validation :normalize_door_type

  belongs_to :product_source, optional: true
  belongs_to :import_batch, optional: true

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :brand, presence: true
  validates :category, presence: true
  validates :currency, presence: true

  enum :door_type, {
    unknown: 'unknown',
    entrance: 'entrance',
    interior: 'interior'
  }, suffix: true

  SEARCHABLE_FIELDS = %i[
    title
    brand
    category
    vendor_code
    description
  ].freeze

  before_save :assign_searchable_text

  scope :active, -> { where(active: true) }
  scope :interior, -> { where(door_type: 'interior') }
  scope :entrance, -> { where(door_type: 'entrance') }

  def to_param
    slug
  end

  def brand_slug
    brand.parameterize
  end

  def category_slug
    category.parameterize
  end

  def self.build_searchable_text_from(attributes)
    SEARCHABLE_FIELDS
      .map { |field| attributes[field] || attributes[field.to_s] }
      .compact
      .join(' ')
      .squish
      .downcase
  end

  private

  def assign_searchable_text
    self.searchable_text = self.class.build_searchable_text_from(attributes)
  end

  def normalize_door_type
    self.door_type = case door_type.to_s.downcase
                     when 'interior', 'межкомнатная', 'межкомнатные', /межкомнат/
                       'interior'
                     when 'entrance', 'входная', 'входные', /вход|метал|термо/
                       'entrance'
                     else
                       'unknown'
                     end
  end
end
