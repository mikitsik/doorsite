# frozen_string_literal: true

class SystemDoor < ApplicationRecord
  scope :active, -> { where(active: true) }

  def to_param
    slug
  end
end
