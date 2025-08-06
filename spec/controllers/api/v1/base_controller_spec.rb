require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :request do
  describe 'BaseController configuration' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::BaseController.superclass).to eq(ApplicationController)
    end
  end

  describe 'CSRF protection behavior' do
    let!(:user) { User.create!(name: 'Test User') }

    it 'allows API requests without CSRF token through inherited controllers' do
      # Test that controllers inheriting from BaseController work without CSRF token
      post "/api/v1/users/#{user.id}/clock_in", as: :json
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Clocked in')
    end

    it 'does not raise InvalidAuthenticityToken error' do
      # This verifies that protect_from_forgery with: :null_session is working
      expect {
        post "/api/v1/users/#{user.id}/clock_in", as: :json
      }.not_to raise_error
    end
  end
end