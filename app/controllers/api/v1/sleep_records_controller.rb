class Api::V1::SleepRecordsController < ApplicationController
  before_action :set_user
  
  def clock_in
    # Check if user has an in-progress sleep record
    in_progress_record = @user.sleep_records.in_progress.first
    
    if in_progress_record
      # Clock out the existing record
      in_progress_record.update!(clock_out: Time.current)
      @message = "Clocked out"
      @sleep_records = @user.sleep_records.order(:created_at)
    else
      # Clock in - create new record
      sleep_record = @user.sleep_records.create!(clock_in: Time.current)
      @message = "Clocked in"
      @sleep_records = @user.sleep_records.order(:created_at)
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def following_sleep_records
    # Use caching for expensive operations
    cache_key = "user_#{@user.id}_following_sleep_records_#{Date.current}"
    
    # Get sleep records from followed users from the previous week
    following_user_ids = @user.following.pluck(:id)
    
    if following_user_ids.empty?
      @following_sleep_records = []
      return
    end
    
    @following_sleep_records = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      SleepRecord.joins(:user)
                 .for_users(following_user_ids)
                 .from_last_week
                 .completed
                 .includes(:user)
                 .select('sleep_records.*, users.name as user_name')
                 .sort_by(&:duration_in_seconds)
                 .reverse
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end


end
