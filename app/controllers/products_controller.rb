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
    @active_category = active_category
    @catalog_expanded = params[:catalog] == 'full'

    @products = Product
                .where(active: true)
                .where(door_type: @active_category)
                .order(created_at: :desc)
                .limit(@catalog_expanded ? 24 : 12)
  end

  def show
    @product = Product.find_by(slug: params[:id]) || Product.find(params[:id])
  end

  private

  def active_category
    return params[:category] if CATALOG_CATEGORIES.include?(params[:category])

    DEFAULT_CATEGORY
  end
end
