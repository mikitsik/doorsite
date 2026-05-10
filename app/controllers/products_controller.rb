# frozen_string_literal: true

class ProductsController < ApplicationController
  PER_PAGE = 24

  def index
    @active_filter = params[:filter].presence || 'all'
    @page = [params[:page].to_i, 1].max

    scope = EntranceDoor.active.order(created_at: :desc)
    scope = apply_filter(scope)

    @total_products = scope.count
    @total_pages = (@total_products.to_f / PER_PAGE).ceil
    @products = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
    redirect_to root_path
  end

  private

  def apply_filter(scope)
    case @active_filter
    when 'street'
      scope.where(use_case: 'уличная')
    when 'thermal'
      scope.where(thermal_break: true)
    when 'apartment'
      scope.where(use_case: 'квартирная')
    when 'glass'
      scope.where.not(glass: [nil, '', 'Без стекла'])
    when 'metal_mdf'
      scope.where(construction_type: 'металл-мдф')
    when 'mdf_mdf'
      scope.where(construction_type: 'мдф-мдф')
    else
      scope
    end
  end
end
