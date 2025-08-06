class Api::V1::FollowsController < ApplicationController
  before_action :set_user
  before_action :set_target_user, only: [:follow, :unfollow]

  def follow
    if @user.following?(@target_user)
      @message = "Already following this user"
      @following = @user.following
    elsif @user == @target_user
      render json: { error: "Cannot follow yourself" }, status: :unprocessable_entity
    else
      @user.follow(@target_user)
      @message = "Successfully followed user"
      @following = @user.following
    end
  end

  def unfollow
    if @user.following?(@target_user)
      @user.unfollow(@target_user)
      @message = "Successfully unfollowed user"
      @following = @user.following
    else
      @message = "Not following this user"
      @following = @user.following
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def set_target_user
    @target_user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Target user not found" }, status: :not_found
  end

end
