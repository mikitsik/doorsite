class ProductsController < ApplicationController
  def index
    @categories = Product.active.distinct.order(:category).pluck(:category)
    @brands = Product.active.distinct.order(:brand).pluck(:brand)

    @products = Product.active
                       .by_category(params[:category])
                       .by_brand(params[:brand])
                       .order(created_at: :desc)
  end

  def show
    @product = Product.active.find_by!(slug: params[:id])
  end
end
