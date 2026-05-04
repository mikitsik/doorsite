# frozen_string_literal: true

class ProductSource < ApplicationRecord
  has_many :import_batches, dependent: :destroy
  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :source_type, presence: true
  validates :sync_strategy, presence: true
end
