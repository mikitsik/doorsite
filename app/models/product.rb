class Product < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :brand, presence: true
  validates :category, presence: true
  validates :currency, presence: true

  scope :active, -> { where(active: true) }

  def to_param
    slug
  end

  def brand_slug
    brand.parameterize
  end

  def category_slug
    category.parameterize
  end
end
