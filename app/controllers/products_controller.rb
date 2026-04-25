class ProductsController < ApplicationController
  def index
    @products = Product.active
    @products = @products.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @products = @products.where(brand: params[:brand]) if params[:brand].present?
    @products = @products.order(created_at: :desc)

    @featured_categories = [
      {
        title: "Входные двери",
        price: "от 420 BYN",
        image_name: "vhodnye-model.webp",
        href: "#catalog"
      },
      {
        title: "Межкомнатные двери",
        price: "от 510 BYN",
        image_name: "mezk-model.webp",
        href: "#catalog"
      },
      {
        title: "Установка входных дверей",
        price: "от 980 BYN",
        image_name: "vhodnye-real.webp",
        href: "#catalog"
      },
      {
        title: "Установка межкомнатных дверей",
        price: "от 380 BYN",
        image_name: "mezk-real.webp",
        href: "#catalog"
      }
    ]

    @brand_links = [
      { name: "Elporta", href: "#catalog", class_name: "brand-link--elporta" },
      { name: "torex", href: "#catalog", class_name: "brand-link--torex" },
      { name: "dverimagna", href: "#catalog", class_name: "brand-link--dverimagna" },
      { name: "ЮРКАС", href: "#catalog", class_name: "brand-link--yurkas" }
    ]

    @steps = [
      {
        number: "01",
        title: "Выберите модель",
        text: "Быстро покажем варианты и поможем определиться с дизайном",
        button: "Подробнее",
        href: "#catalog",
        card_class: "step-card--blue"
      },
      {
        number: "02",
        title: "Свяжитесь с нами",
        text: "Быстро уточним размеры и подскажем лучший вариант",
        button: "Позвонить",
        href: "tel:+375292746635",
        card_class: "step-card--orange"
      },
      {
        number: "03",
        title: "Согласуем детали",
        text: "Уточним доставку, установку и итоговую стоимость",
        button: "Открыть каталог",
        href: "#catalog",
        card_class: "step-card--orange-2"
      }
    ]
  end

  def show
    @product = Product.active.find_by!(slug: params[:id])
  end
end
