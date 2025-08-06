class Api::V1::SleepRecordsController < Api::V1::BaseController
  def clock_in
    # Check if user has an in-progress sleep record
    in_progress_record = current_user.sleep_records.in_progress.first

    if in_progress_record
      # Clock out the existing record
      in_progress_record.update!(clock_out: Time.current)
      @message = "Clocked out"
      @sleep_records = current_user.sleep_records.order(:created_at)
    else
      # Clock in - create new record
      sleep_record = current_user.sleep_records.create!(clock_in: Time.current)
      @message = "Clocked in"
      @sleep_records = current_user.sleep_records.order(:created_at)
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def following_sleep_records
    # Use caching for expensive operations
    cache_key = "user_#{current_user.id}_following_sleep_records_#{Date.current}"

    # Get sleep records from followed users from the previous week
    following_user_ids = current_user.following.pluck(:id)

    if following_user_ids.empty?
      @following_sleep_records = []
      return
    end

    @following_sleep_records =
      SleepRecord.joins(:user)
                 .for_users(following_user_ids)
                 .from_last_week
                 .completed
                 .includes(:user)
                 .select("sleep_records.*, users.name as user_name")
                 .sort_by(&:duration_in_seconds)
                 .reverse
  end
end
