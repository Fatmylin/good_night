class Api::V1::FollowsController < Api::V1::BaseController
  before_action :set_target_user, only: [:follow, :unfollow]

  def follow
    if current_user.following?(@target_user)
      @message = "Already following this user"
      @following = current_user.following
    elsif current_user == @target_user
      render json: { error: "Cannot follow yourself" }, status: :unprocessable_entity
    else
      current_user.follow(@target_user)
      @message = "Successfully followed user"
      @following = current_user.following
    end
  end

  def unfollow
    if current_user.following?(@target_user)
      current_user.unfollow(@target_user)
      @message = "Successfully unfollowed user"
      @following = current_user.following
    else
      @message = "Not following this user"
      @following = current_user.following
    end
  end

  private

  def set_target_user
    @target_user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Target user not found" }, status: :not_found
  end
end
