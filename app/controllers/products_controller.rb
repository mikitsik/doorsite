# frozen_string_literal: true

class ProductsController < ApplicationController
  def index; end

  def show
    redirect_to root_path
  end
end
