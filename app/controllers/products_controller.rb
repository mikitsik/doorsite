# frozen_string_literal: true

class ProductsController < ApplicationController
  PER_PAGE = 24

  def index
    @page = [params[:page].to_i, 1].max

    scope = EntranceDoor.active.order(created_at: :desc)

    @total_products = scope.count
    @total_pages = (@total_products.to_f / PER_PAGE).ceil
    @products = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
    @product = EntranceDoor.find(params[:id])
  end
end
