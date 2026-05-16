# frozen_string_literal: true

class ProductsController < ApplicationController
  CATALOG_MODELS = {
    'entrance_doors' => EntranceDoor,
    'interior_doors' => InteriorDoor,
    'system_doors' => SystemDoor
  }.freeze

  DEFAULT_CATALOG_TYPE = 'entrance_doors'
  PER_PAGE = 18

  def index
    @catalog_type = selected_catalog_type
    @brands = selected_model.active.where.not(brand: [nil, '']).distinct.order(:brand).pluck(:brand)
    @page = [params[:page].to_i, 1].max

    scope = selected_model.active.order(created_at: :desc)
    scope = scope.where(brand: params[:brands]) if params[:brands].present?

    @total_products = scope.count
    @total_pages = (@total_products.to_f / PER_PAGE).ceil
    @products = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @filters_open = params[:filters] == 'open'
  end

  def show_entrance_door
    @product = EntranceDoor.find_by!(slug: params[:slug])
    render :show_entrance_door
  end

  def show_interior_door
    @product = InteriorDoor.find_by!(slug: params[:slug])

    @variants = InteriorDoor
                .active
                .where(model_group_key: @product.model_group_key)
                .order(:series, :vendor_color, :glass)

    render :show_interior_door
  end

  def show_system_door
    @product = SystemDoor.find_by!(slug: params[:slug])
    render :show_system_door
  end

  private

  def selected_catalog_type
    params[:catalog_type].presence_in(CATALOG_MODELS.keys) || DEFAULT_CATALOG_TYPE
  end

  def selected_model
    @selected_model ||= CATALOG_MODELS.fetch(@catalog_type)
  end
end
