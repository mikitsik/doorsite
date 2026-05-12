# frozen_string_literal: true

Rails.application.routes.draw do
  root 'products#index'

  get '/vhodnaya-dver/:slug',
      to: 'products#show_entrance_door',
      as: :entrance_door

  get '/mezhkomnatnaya-dver/:slug',
      to: 'products#show_interior_door',
      as: :interior_door

  get '/dvernaya-sistema/:slug',
      to: 'products#show_system_door',
      as: :system_door
end
