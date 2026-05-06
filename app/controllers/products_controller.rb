# frozen_string_literal: true

class ProductsController < ApplicationController
  CATALOG_CATEGORIES = %w[
    entrance
    interior
    systems
    hardware
  ].freeze

  DEFAULT_CATEGORY = 'entrance'

  def index
    @products = Product
                .where(active: true)
                .then { |scope| filter_by_catalog_category(scope) }
                .order(created_at: :desc)
                .limit(@catalog_expanded ? 24 : 12)
  end

  def show; end

  private

  def active_category
    return params[:category] if CATALOG_CATEGORIES.include?(params[:category])

    DEFAULT_CATEGORY
  end

  def filter_by_catalog_category(scope)
    case @active_category
    when "entrance"
      scope.where(door_type: "entrance")
    when "interior"
      scope.where(door_type: "interior")
    when "systems"
      scope.where(
        "source_category ILIKE :q OR category ILIKE :q OR searchable_text ILIKE :q",
        q: "%раздвиж%"
      )
    when "hardware"
      scope.where(
        "source_category ILIKE :q OR category ILIKE :q OR searchable_text ILIKE :q",
        q: "%фурнитур%"
      )
    else
      scope
    end
  end
end
