# frozen_string_literal: true

class ProductsController < ApplicationController
  def index
    @products = Product.active
    @products = @products.where('title ILIKE ?', "%#{params[:q]}%") if params[:q].present?
    @products = @products.where(brand: params[:brand]) if params[:brand].present?
    @products = @products.order(created_at: :desc)

    @featured_categories = [
      {
        title: 'Входные двери',
        price: 'от 420 BYN',
        image_name: 'vhodnye-model.webp',
        href: '#catalog'
      },
      {
        title: 'Межкомнатные двери',
        price: 'от 510 BYN',
        image_name: 'mezk-model.webp',
        href: '#catalog'
      },
      {
        title: 'Дверные системы',
        price: 'от 980 BYN',
        image_name: 'system.webp',
        href: '#catalog'
      },
      {
        title: 'Фурнитура',
        price: 'от 380 BYN',
        image_name: 'furniture.webp',
        href: '#catalog'
      }
    ]
  end

  def show
    @product = Product.active.find_by!(slug: params[:id])
  end
end
