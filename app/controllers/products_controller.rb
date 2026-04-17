class ProductsController < ApplicationController
  def index
    @brands = Product.active.distinct.order(:brand).pluck(:brand)

    @products = Product.active
    @products = @products.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @products = @products.where(brand: params[:brand]) if params[:brand].present?
    @products = @products.order(created_at: :desc)

    @featured_products = Product.active.limit(4)

    @steps = [
      {
        number: "01",
        title: "Выберите модель",
        text: "Поможем подобрать дверь под интерьер и бюджет",
        button: "Подробнее"
      },
      {
        number: "02",
        title: "Свяжитесь с нами",
        text: "Быстро уточним размеры и подскажем лучший вариант",
        button: "Позвонить"
      },
      {
        number: "03",
        title: "Согласуем",
        text: "Уточним доставку, установку и итоговую стоимость",
        button: "Открыть каталог"
      }
    ]
  end

  def show
    @product = Product.active.find_by!(slug: params[:id])
  end
end
