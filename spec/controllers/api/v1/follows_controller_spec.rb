require 'rails_helper'

RSpec.describe Api::V1::FollowsController, type: :request do
  let!(:alice) { User.create!(name: 'Alice Johnson') }
  let!(:bob) { User.create!(name: 'Bob Smith') }
  let!(:charlie) { User.create!(name: 'Charlie Brown') }

  # Set up initial follow relationships
  before do
    alice.follow(bob)
    alice.follow(charlie)
    bob.follow(charlie)
  end

  describe 'POST /api/v1/users/:user_id/follow/:id' do
    context 'when following a new user' do
      it 'creates a new follow relationship' do
        expect(bob.following?(alice)).to be false

        expect {
          post "/api/v1/users/#{bob.id}/follow/#{alice.id}", as: :json
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Successfully followed user')

        expect(bob.reload.following?(alice)).to be true

        # Check the following list in response
        following_names = response_data['following'].map { |u| u['name'] }
        expect(following_names).to include('Alice Johnson')
        expect(following_names).to include('Charlie Brown')
      end
    end

    context 'when already following user' do
      it 'returns appropriate message without creating duplicate' do
        expect(alice.following?(bob)).to be true

        expect {
          post "/api/v1/users/#{alice.id}/follow/#{bob.id}", as: :json
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Already following this user')
      end
    end

    context 'when trying to follow yourself' do
      it 'prevents self-following' do
        expect {
          post "/api/v1/users/#{alice.id}/follow/#{alice.id}", as: :json
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        response_data = JSON.parse(response.body)
        expect(response_data['error']).to eq('Cannot follow yourself')
      end
    end

    it 'returns current following list after follow action' do
      post "/api/v1/users/#{bob.id}/follow/#{alice.id}", as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)

      expect(response_data).to have_key('following')
      expect(response_data['following']).to be_an(Array)

      following_names = response_data['following'].map { |u| u['name'] }
      expect(following_names).to include('Alice Johnson')
      expect(following_names).to include('Charlie Brown')
    end

    context 'with non-existent user' do
      it 'returns 404 for non-existent user' do
        post "/api/v1/users/99999/follow/#{bob.id}", as: :json

        expect(response).to have_http_status(:not_found)
        response_data = JSON.parse(response.body)
        expect(response_data['error']).to eq('User not found')
      end

      it 'returns 404 for non-existent target user' do
        post "/api/v1/users/#{alice.id}/follow/99999", as: :json

        expect(response).to have_http_status(:not_found)
        response_data = JSON.parse(response.body)
        expect(response_data['error']).to eq('Target user not found')
      end
    end
  end

  describe 'DELETE /api/v1/users/:user_id/follow/:id' do
    context 'when unfollowing a followed user' do
      it 'removes the follow relationship' do
        expect(alice.following?(bob)).to be true

        expect {
          delete "/api/v1/users/#{alice.id}/follow/#{bob.id}", as: :json
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Successfully unfollowed user')

        expect(alice.reload.following?(bob)).to be false

        # Check the updated following list
        following_names = response_data['following'].map { |u| u['name'] }
        expect(following_names).not_to include('Bob Smith')
        expect(following_names).to include('Charlie Brown')
      end
    end

    context 'when unfollowing user not being followed' do
      it 'handles gracefully' do
        expect(charlie.following?(alice)).to be false

        expect {
          delete "/api/v1/users/#{charlie.id}/follow/#{alice.id}", as: :json
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Not following this user')
      end
    end

    it 'returns updated following list after unfollow action' do
      delete "/api/v1/users/#{alice.id}/follow/#{bob.id}", as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)

      expect(response_data).to have_key('following')
      following_names = response_data['following'].map { |u| u['name'] }

      expect(following_names).not_to include('Bob Smith')
      expect(following_names).to include('Charlie Brown')
    end
  end
end
