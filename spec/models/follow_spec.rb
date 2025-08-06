require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { User.create!(name: 'Alice Johnson', email: 'alice@example.com', password: 'password123') }
  let(:bob) { User.create!(name: 'Bob Smith', email: 'bob@example.com', password: 'password123') }
  let(:charlie) { User.create!(name: 'Charlie Brown', email: 'charlie@example.com', password: 'password123') }

  describe 'validations' do
    subject { Follow.new(follower: alice, followed: bob) }

    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:followed_id) }
    it { should validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }

    it 'should prevent following yourself' do
      follow = Follow.new(follower: alice, followed: alice)
      expect(follow).to be_invalid
      expect(follow.errors[:followed_id]).to include('cannot follow yourself')
    end
  end

  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end

  describe 'valid follow relationships' do
    it 'should create valid follow relationship' do
      follow = Follow.new(follower: alice, followed: bob)
      expect(follow).to be_valid
    end

    it 'should prevent duplicate follow relationships' do
      Follow.create!(follower: alice, followed: bob)
      duplicate_follow = Follow.new(follower: alice, followed: bob)
      expect(duplicate_follow).to be_invalid
      expect(duplicate_follow.errors[:follower_id]).to include('has already been taken')
    end

    it 'should allow same user to be followed by different users' do
      follow1 = Follow.new(follower: alice, followed: charlie)
      follow2 = Follow.new(follower: bob, followed: charlie)

      expect(follow1).to be_valid
      expect(follow2).to be_valid

      follow1.save!
      expect(follow2).to be_valid
    end

    it 'should allow user to follow multiple users' do
      follow1 = Follow.new(follower: alice, followed: bob)
      follow2 = Follow.new(follower: alice, followed: charlie)

      expect(follow1).to be_valid
      expect(follow2).to be_valid

      follow1.save!
      expect(follow2).to be_valid
    end
  end

  describe 'referential integrity' do
    it 'should maintain proper associations' do
      follow = Follow.create!(follower: alice, followed: bob)

      expect(follow.follower).to eq(alice)
      expect(follow.followed).to eq(bob)
      expect(follow.follower).to be_a(User)
      expect(follow.followed).to be_a(User)
    end

    it 'should enforce unique constraint at database level' do
      Follow.create!(follower: alice, followed: bob)

      expect {
        Follow.create!(follower: alice, followed: bob)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
