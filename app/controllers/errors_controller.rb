# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    render template: 'errors/not_found',
           status: :not_found,
           formats: [:html]
  end
end
