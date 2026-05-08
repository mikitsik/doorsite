# frozen_string_literal: true

class ProductsController < ApplicationController
  CATALOG_CATEGORIES = %w[
    entrance
    interior
    systems
    hardware
  ].freeze

  DEFAULT_CATEGORY = 'entrance'

  PRODUCTS_PER_PAGE = 24

  def index
    @active_category = active_category
    @active_filter = params[:filter].presence || 'all'
    @catalog_expanded = true

    products_scope = Product
                     .where(active: true)
                     .where(door_type: @active_category)

    products_scope = apply_catalog_filter(products_scope)

    @page = params[:page].to_i
    @page = 1 if @page < 1

    @total_products = products_scope.count
    @total_pages = (@total_products.to_f / PRODUCTS_PER_PAGE).ceil

    @products = products_scope
                .order(created_at: :desc)
                .offset((@page - 1) * PRODUCTS_PER_PAGE)
                .limit(PRODUCTS_PER_PAGE)
  end

  def apply_catalog_filter(scope)
    return scope if @active_filter == 'all'

    keywords = catalog_filter_keywords.fetch(@active_category, {}).fetch(@active_filter, [])
    return scope if keywords.blank?

    query = keywords.map { 'searchable_text ILIKE ? OR source_category ILIKE ? OR category ILIKE ?' }.join(' OR ')
    values = keywords.flat_map { |keyword| ["%#{keyword}%", "%#{keyword}%", "%#{keyword}%"] }

    scope.where(query, *values)
  end

  def catalog_filter_keywords
    {
      'entrance' => {
        'street' => %w[улич],
        'thermal' => %w[термо терморазрыв],
        'apartment' => %w[квартир],
        'glass' => %w[стеклопакет стекл],
        'metal_mdf' => ['металл-мдф'],
        'mdf_mdf' => ['мдф-мдф']
      },
      'interior' => {
        'eco_veneer' => ['экошпон', 'эко шпон'],
        'enamel' => %w[эмаль],
        'pvc' => %w[пвх],
        'massive' => %w[массив],
        'veneer' => %w[шпон],
        'cpl' => %w[cpl],
        'polypropylene' => %w[полипропилен]
      }
    }
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
