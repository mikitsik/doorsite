# frozen_string_literal: true

class CatalogCategory < ApplicationRecord
  KINDS = %w[
    entrance
    interior
    systems
    hardware
  ].freeze

  belongs_to :parent, class_name: 'CatalogCategory', optional: true
  has_many :children, class_name: 'CatalogCategory', foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent
  has_many :products, dependent: :nullify

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :source, presence: true
  validates :source_category_id, uniqueness: { scope: :source }, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :title) }

  def to_param
    slug
  end
end
