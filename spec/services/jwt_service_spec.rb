require 'rails_helper'

RSpec.describe JwtService do
  let(:payload) { { user_id: 123, name: 'Test User' } }
  
  describe '.encode' do
    it 'encodes payload into JWT token' do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end
    
    it 'includes expiration time in payload' do
      exp_time = 2.hours.from_now
      token = JwtService.encode(payload, exp_time)
      
      decoded = JWT.decode(token, JwtService::SECRET_KEY)[0]
      expect(decoded['exp']).to eq(exp_time.to_i)
    end
    
    it 'defaults to 24 hours expiration' do
      token = JwtService.encode(payload)
      
      decoded = JWT.decode(token, JwtService::SECRET_KEY)[0]
      expect(decoded['exp']).to be_within(5.seconds).of(24.hours.from_now.to_i)
    end
  end
  
  describe '.decode' do
    let(:token) { JwtService.encode(payload) }
    
    it 'decodes valid JWT token' do
      decoded = JwtService.decode(token)
      
      expect(decoded).to be_a(HashWithIndifferentAccess)
      expect(decoded[:user_id]).to eq(123)
      expect(decoded[:name]).to eq('Test User')
    end
    
    it 'returns nil for invalid token' do
      invalid_token = 'invalid.jwt.token'
      
      expect(JwtService.decode(invalid_token)).to be_nil
    end
    
    it 'returns nil for expired token' do
      expired_token = JwtService.encode(payload, 1.hour.ago)
      
      expect(JwtService.decode(expired_token)).to be_nil
    end
    
    it 'returns nil for token with wrong secret' do
      wrong_secret_token = JWT.encode(payload, 'wrong_secret')
      
      expect(JwtService.decode(wrong_secret_token)).to be_nil
    end
  end
end