require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password123') }

  describe 'validations' do
    it { should validate_presence_of(:clock_in) }
    it { should belong_to(:user) }

    it 'should validate clock_out after clock_in' do
      clock_in_time = Time.current
      sleep_record = SleepRecord.new(
        user: user,
        clock_in: clock_in_time,
        clock_out: clock_in_time - 1.hour
      )

      expect(sleep_record).to be_invalid
      expect(sleep_record.errors[:clock_out]).to include('must be after clock in time')
    end

    it 'should create sleep record with valid clock_in' do
      sleep_record = SleepRecord.new(user: user, clock_in: Time.current)
      expect(sleep_record).to be_valid
    end
  end

  describe 'scopes' do
    let!(:completed_record) do
      SleepRecord.create!(
        user: user,
        clock_in: Time.current - 8.hours,
        clock_out: Time.current
      )
    end

    let!(:in_progress_record) do
      SleepRecord.create!(
        user: user,
        clock_in: Time.current
      )
    end

    let!(:old_record) do
      record = SleepRecord.create!(
        user: user,
        clock_in: 2.weeks.ago,
        clock_out: 2.weeks.ago + 8.hours
      )
      record.update_column(:created_at, 2.weeks.ago)
      record
    end

    describe '.completed' do
      it 'returns only completed records' do
        expect(SleepRecord.completed).to include(completed_record)
        expect(SleepRecord.completed).not_to include(in_progress_record)
      end
    end

    describe '.in_progress' do
      it 'returns only in-progress records' do
        expect(SleepRecord.in_progress).to include(in_progress_record)
        expect(SleepRecord.in_progress).not_to include(completed_record)
      end
    end

    describe '.from_last_week' do
      it 'returns records created within last week' do
        expect(SleepRecord.from_last_week).to include(completed_record)
        expect(SleepRecord.from_last_week).to include(in_progress_record)
        expect(SleepRecord.from_last_week).not_to include(old_record)
      end
    end

    describe '.for_users' do
      let(:other_user) { User.create!(name: 'Other User', email: 'other@example.com', password: 'password123') }
      let!(:other_user_record) { SleepRecord.create!(user: other_user, clock_in: Time.current) }

      it 'returns records for specified users' do
        expect(SleepRecord.for_users([ user.id ])).to include(completed_record, in_progress_record)
        expect(SleepRecord.for_users([ user.id ])).not_to include(other_user_record)
      end
    end
  end

  describe 'instance methods' do
    describe '#duration_in_seconds' do
      it 'calculates duration correctly for completed records' do
        clock_in_time = Time.current
        clock_out_time = clock_in_time + 8.hours

        sleep_record = SleepRecord.new(
          user: user,
          clock_in: clock_in_time,
          clock_out: clock_out_time
        )

        expect(sleep_record.duration_in_seconds).to eq(28800) # 8 hours * 3600 seconds
      end

      it 'returns nil for incomplete records' do
        sleep_record = SleepRecord.new(user: user, clock_in: Time.current)
        expect(sleep_record.duration_in_seconds).to be_nil
      end
    end

    describe '#duration_in_hours' do
      it 'calculates duration in hours correctly' do
        clock_in_time = Time.current
        clock_out_time = clock_in_time + 8.hours

        sleep_record = SleepRecord.new(
          user: user,
          clock_in: clock_in_time,
          clock_out: clock_out_time
        )

        expect(sleep_record.duration_in_hours).to eq(8.0)
      end

      it 'returns nil for incomplete records' do
        sleep_record = SleepRecord.new(user: user, clock_in: Time.current)
        expect(sleep_record.duration_in_hours).to be_nil
      end
    end

    describe '#completed?' do
      it 'returns true for records with clock_out' do
        sleep_record = SleepRecord.new(
          user: user,
          clock_in: Time.current - 8.hours,
          clock_out: Time.current
        )
        expect(sleep_record.completed?).to be true
      end

      it 'returns false for records without clock_out' do
        sleep_record = SleepRecord.new(user: user, clock_in: Time.current)
        expect(sleep_record.completed?).to be false
      end
    end

    describe '#in_progress?' do
      it 'returns false for completed records' do
        sleep_record = SleepRecord.new(
          user: user,
          clock_in: Time.current - 8.hours,
          clock_out: Time.current
        )
        expect(sleep_record.in_progress?).to be false
      end

      it 'returns true for records without clock_out' do
        sleep_record = SleepRecord.new(user: user, clock_in: Time.current)
        expect(sleep_record.in_progress?).to be true
      end
    end
  end
end
