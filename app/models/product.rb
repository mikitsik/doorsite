# frozen_string_literal: true

class Product < ApplicationRecord
  DOOR_TYPES = %w[
    entrance
    interior
    systems
    hardware
  ].freeze

  SEARCHABLE_FIELDS = %i[
    title
    brand
    dealer
    category
    collection
    vendor_code
    color
    material
    finish
    glass
    description
  ].freeze

  belongs_to :product_source, optional: true
  belongs_to :import_batch, optional: true
  belongs_to :catalog_category, optional: true

  before_validation :normalize_door_type
  before_save :assign_searchable_text

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :brand, presence: true
  validates :category, presence: true
  validates :currency, presence: true
  validates :door_type, inclusion: { in: DOOR_TYPES }

  enum :door_type, {
    entrance: 'entrance',
    interior: 'interior',
    systems: 'systems',
    hardware: 'hardware'
  }, suffix: true

  scope :active, -> { where(active: true) }
  scope :entrance, -> { where(door_type: 'entrance') }
  scope :interior, -> { where(door_type: 'interior') }
  scope :systems, -> { where(door_type: 'systems') }
  scope :hardware, -> { where(door_type: 'hardware') }
  scope :by_catalog_section, ->(section) { where(catalog_section: section) }
  scope :ordered_by_catalog, -> { joins(:catalog_category).order('catalog_categories.position ASC', :brand, :title) }

  def to_param
    slug
  end

  def brand_slug
    brand.to_s.parameterize
  end

  def category_slug
    category.to_s.parameterize
  end

  def self.build_searchable_text_from(attributes)
    SEARCHABLE_FIELDS
      .filter_map { |field| attributes[field] || attributes[field.to_s] }
      .join(' ')
      .squish
      .downcase
  end

  private

  def assign_searchable_text
    self.searchable_text = self.class.build_searchable_text_from(attributes)
  end

  def normalize_door_type
    self.door_type = normalized_door_type
  end

  def normalized_door_type
    source = [
      door_type,
      category,
      source_category,
      title
    ].compact.join(' ').downcase

    return 'entrance' if source.match?(/entrance|вход|метал|термо|улич|квартир/)
    return 'interior' if source.match?(/interior|межкомнат|эмаль|экошпон|эко шпон|шпон|массив|пвх|cpl/)

    hardware_pattern = /
      hardware|
      фурнитур|
      ручк|
      замок|
      замки|
      защ[её]лк|
      петл|
      цилиндр|
      фиксатор|
      накладк|
      шпингалет|
      упор|
      ролик|
      глазок
    /x

    return 'hardware' if source.match?(hardware_pattern)

    'systems'
  end
end
