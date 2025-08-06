require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it { should have_many(:follower_follows).class_name('Follow').with_foreign_key('follower_id').dependent(:destroy) }
    it { should have_many(:followed_follows).class_name('Follow').with_foreign_key('followed_id').dependent(:destroy) }
    it { should have_many(:following).through(:follower_follows).source(:followed) }
    it { should have_many(:followers).through(:followed_follows).source(:follower) }
  end

  describe 'methods' do
    let(:alice) { User.create!(name: 'Alice Johnson', email: 'alice@example.com', password: 'password123') }
    let(:bob) { User.create!(name: 'Bob Smith', email: 'bob@example.com', password: 'password123') }
    let(:charlie) { User.create!(name: 'Charlie Brown', email: 'charlie@example.com', password: 'password123') }

    describe '#follow' do
      it 'should follow another user' do
        alice.follow(bob)
        expect(alice.following?(bob)).to be true
        expect(bob.followers).to include(alice)
      end

      it 'should not follow same user twice' do
        alice.follow(bob)
        initial_count = alice.following.count
        alice.follow(bob)
        expect(alice.following.count).to eq(initial_count)
      end

      it 'should not follow self' do
        initial_count = alice.following.count
        alice.follow(alice)
        expect(alice.following.count).to eq(initial_count)
        expect(alice.following?(alice)).to be false
      end
    end

    describe '#unfollow' do
      it 'should unfollow user' do
        alice.follow(bob)
        expect(alice.following?(bob)).to be true

        alice.unfollow(bob)
        expect(alice.following?(bob)).to be false
      end
    end

    describe '#following?' do
      it 'should check if following user' do
        alice.follow(bob)
        alice.follow(charlie)

        expect(alice.following?(bob)).to be true
        expect(alice.following?(charlie)).to be true
        expect(alice.following?(alice)).to be false
      end
    end
  end
end
