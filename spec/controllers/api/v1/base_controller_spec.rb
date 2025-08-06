require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :request do
  describe 'BaseController configuration' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::BaseController.superclass).to eq(ApplicationController)
    end
  end

  describe 'JWT authentication' do
    let!(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password') }
    let(:token) { JwtService.encode(user_id: user.id) }
    
    context 'with valid JWT token' do
      it 'allows authenticated requests' do
        post '/api/v1/clock_in', 
             headers: { 'Authorization' => "Bearer #{token}" }, 
             as: :json
        
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['message']).to eq('Clocked in')
      end
    end
    
    context 'without JWT token' do
      it 'returns unauthorized error' do
        post '/api/v1/clock_in', as: :json
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
    
    context 'with invalid JWT token' do
      it 'returns unauthorized error' do
        post '/api/v1/clock_in', 
             headers: { 'Authorization' => 'Bearer invalid_token' }, 
             as: :json
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
    
    context 'with expired JWT token' do
      it 'returns unauthorized error' do
        expired_token = JwtService.encode({ user_id: user.id }, 1.hour.ago)
        
        post '/api/v1/clock_in', 
             headers: { 'Authorization' => "Bearer #{expired_token}" }, 
             as: :json
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end
end