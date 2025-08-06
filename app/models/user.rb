class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :sleep_records, dependent: :destroy
  
  has_many :follower_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :followed_follows, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy
  
  has_many :following, through: :follower_follows, source: :followed
  has_many :followers, through: :followed_follows, source: :follower

  def follow(other_user)
    following << other_user unless following?(other_user) || self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
