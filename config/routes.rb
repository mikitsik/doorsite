Rails.application.routes.draw do
  root "products#index"

  resources :products, only: [ :index, :show ]

  # SEO-filters
  get "brands/:brand", to: "products#index", as: :brand
  get "categories/:category", to: "products#index", as: :category

  get "up" => "rails/health#show", as: :rails_health_check
end
