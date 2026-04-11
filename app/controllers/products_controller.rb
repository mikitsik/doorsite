class ProductsController < ApplicationController
  PRODUCTS_PER_PAGE = 24

  def index
    @visible_count = visible_count
    base_scope = Product.active.where("LOWER(brand) = ?", "elporta").order(:title)

    @products = base_scope.limit(@visible_count)
    @total_products_count = base_scope.count
    @show_more = @visible_count < @total_products_count
  end

  def show
    @product = Product.active.find_by!(slug: params[:id])
  end

  private

  def visible_count
    count = params.fetch(:limit, PRODUCTS_PER_PAGE).to_i
    return PRODUCTS_PER_PAGE if count <= 0

    count
  end
end
