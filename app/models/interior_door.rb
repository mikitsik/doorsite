# frozen_string_literal: true

class InteriorDoor < ApplicationRecord
  scope :active, -> { where(active: true) }

  def to_param
    slug
  end
end
