# frozen_string_literal: true

class ImportBatch < ApplicationRecord
  belongs_to :product_source
  has_many :products, dependent: :nullify

  STATUSES = %w[pending processing done failed].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
end
