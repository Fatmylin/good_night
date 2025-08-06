require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  describe 'POST /api/v1/signup' do
    let(:valid_params) do
      {
        user: {
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new user and returns JWT token' do
        expect {
          post '/api/v1/signup', params: valid_params, as: :json
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        response_data = JSON.parse(response.body)
        expect(response_data['token']).to be_present
        expect(response_data['user']['name']).to eq('John Doe')
        expect(response_data['user']['email']).to eq('john@example.com')
        expect(response_data['user']['id']).to be_present
      end
      
      it 'returns a valid JWT token' do
        post '/api/v1/signup', params: valid_params, as: :json
        
        response_data = JSON.parse(response.body)
        token = response_data['token']
        
        decoded = JwtService.decode(token)
        expect(decoded).to be_present
        expect(decoded['user_id']).to eq(User.last.id)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns errors for missing email' do
        invalid_params = valid_params.dup
        invalid_params[:user][:email] = ''
        
        post '/api/v1/signup', params: invalid_params, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to include("Email can't be blank")
      end
      
      it 'returns errors for duplicate email' do
        User.create!(name: 'Existing User', email: 'john@example.com', password: 'password')
        
        post '/api/v1/signup', params: valid_params, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to include("Email has already been taken")
      end
    end
  end
  
  describe 'POST /api/v1/login' do
    let!(:user) { User.create!(name: 'Jane Doe', email: 'jane@example.com', password: 'password123') }
    
    context 'with valid credentials' do
      it 'returns JWT token and user data' do
        post '/api/v1/login', params: { email: 'jane@example.com', password: 'password123' }, as: :json
        
        expect(response).to have_http_status(:success)
        
        response_data = JSON.parse(response.body)
        expect(response_data['token']).to be_present
        expect(response_data['user']['name']).to eq('Jane Doe')
        expect(response_data['user']['email']).to eq('jane@example.com')
        expect(response_data['user']['id']).to eq(user.id)
      end
      
      it 'returns a valid JWT token' do
        post '/api/v1/login', params: { email: 'jane@example.com', password: 'password123' }, as: :json
        
        response_data = JSON.parse(response.body)
        token = response_data['token']
        
        decoded = JwtService.decode(token)
        expect(decoded).to be_present
        expect(decoded['user_id']).to eq(user.id)
      end
    end
    
    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post '/api/v1/login', params: { email: 'jane@example.com', password: 'wrongpassword' }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        response_data = JSON.parse(response.body)
        expect(response_data['error']).to eq('Invalid email or password')
      end
      
      it 'returns error for non-existent email' do
        post '/api/v1/login', params: { email: 'nonexistent@example.com', password: 'password123' }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        response_data = JSON.parse(response.body)
        expect(response_data['error']).to eq('Invalid email or password')
      end
    end
  end
end