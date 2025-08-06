require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :request do
  let!(:alice) { User.create!(name: 'Alice Johnson', email: 'alice@example.com', password: 'password123') }
  let!(:bob) { User.create!(name: 'Bob Smith', email: 'bob@example.com', password: 'password123') }
  let!(:charlie) { User.create!(name: 'Charlie Brown', email: 'charlie@example.com', password: 'password123') }

  let(:alice_token) { JwtService.encode(user_id: alice.id) }
  let(:bob_token) { JwtService.encode(user_id: bob.id) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{alice_token}" } }

  # Set up some test data
  before do
    # Alice follows Bob and Charlie
    alice.follow(bob)
    alice.follow(charlie)

    # Create some completed sleep records
    SleepRecord.create!(
      user: bob,
      clock_in: 1.day.ago,
      clock_out: 1.day.ago + 8.hours
    )

    SleepRecord.create!(
      user: charlie,
      clock_in: 2.days.ago,
      clock_out: 2.days.ago + 6.hours
    )

    # Create an in-progress record for Bob
    SleepRecord.create!(
      user: bob,
      clock_in: Time.current
    )
  end

  describe 'POST /api/v1/sleep_records' do
    context 'for user with no existing sleep records' do
      let(:new_user) { User.create!(name: 'New User', email: 'newuser@example.com', password: 'password123') }

      it 'creates a new sleep record' do
        expect {
          post "/api/v1/sleep_records", headers: { 'Authorization' => "Bearer #{JwtService.encode(user_id: new_user.id)}" }, as: :json
        }.to change(SleepRecord, :count).by(1)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Clocked in')
        expect(response_data['sleep_records'].length).to eq(1)

        sleep_record = response_data['sleep_records'].first
        expect(sleep_record['clock_in']).not_to be_nil
        expect(sleep_record['clock_out']).to be_nil
      end
    end

    context 'for user with existing in-progress sleep record' do
      it 'clocks out the existing record' do
        expect {
          post "/api/v1/sleep_records", headers: { 'Authorization' => "Bearer #{bob_token}" }, as: :json
        }.not_to change(SleepRecord, :count)

        expect(response).to have_http_status(:success)

        response_data = JSON.parse(response.body)
        expect(response_data['message']).to eq('Clocked out')

        # Verify the ongoing record was completed
        ongoing_record = bob.sleep_records.in_progress.first
        expect(ongoing_record).to be_nil
      end
    end

    it 'returns sleep records ordered by creation time' do
      # Create multiple records for Alice
      SleepRecord.create!(user: alice, clock_in: 2.days.ago, clock_out: 2.days.ago + 7.hours)
      SleepRecord.create!(user: alice, clock_in: 1.day.ago, clock_out: 1.day.ago + 8.hours)

      post "/api/v1/sleep_records", headers: auth_headers, as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)

      # Check if ordered by created_at
      created_times = response_data['sleep_records'].map { |r| Time.parse(r['created_at']) }
      expect(created_times).to eq(created_times.sort)
    end

    it 'returns unauthorized without valid token' do
      post '/api/v1/sleep_records', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/sleep_records' do
    it 'returns following users sleep records from last week' do
      get "/api/v1/sleep_records", headers: auth_headers, as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)

      # Should contain sleep records from Bob and Charlie from last week
      user_names = response_data.map { |r| r['user_name'] }.uniq
      expect(user_names).to include('Bob Smith')
      expect(user_names).to include('Charlie Brown')

      # Should only include completed records (clock_out present)
      response_data.each do |record|
        expect(record['clock_out']).not_to be_nil
        expect(record['duration_hours']).not_to be_nil
      end
    end

    it 'sorts following sleep records by duration descending' do
      get "/api/v1/sleep_records", headers: auth_headers, as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)

      # Should be sorted by duration (longest first)
      durations = response_data.map { |r| r['duration_hours'] }
      expect(durations).to eq(durations.sort.reverse)
    end

    it 'returns empty array if user follows no one' do
      get "/api/v1/sleep_records", headers: { 'Authorization' => "Bearer #{JwtService.encode(user_id: charlie.id)}" }, as: :json

      expect(response).to have_http_status(:success)
      response_data = JSON.parse(response.body)
      expect(response_data).to eq([])
    end

    it 'returns unauthorized without valid token' do
      get '/api/v1/sleep_records', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
