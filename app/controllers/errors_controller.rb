# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'application'

  def not_found
    render status: :not_found
  end
end
