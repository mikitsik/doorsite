class Product < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :brand, presence: true
  validates :category, presence: true
  validates :currency, presence: true

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { category.present? ? where(category: category) : all }
  scope :by_brand, ->(brand) { brand.present? ? where(brand: brand) : all }

  def to_param
    slug
  end
end
