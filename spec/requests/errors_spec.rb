# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'GET unmatched route' do
    it 'returns http not found' do
      get '/53hj'

      expect(response).to have_http_status(:not_found)
    end
  end
end
