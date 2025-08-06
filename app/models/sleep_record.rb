class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validate :clock_out_after_clock_in, if: :clock_out

  scope :completed, -> { where.not(clock_out: nil) }
  scope :in_progress, -> { where(clock_out: nil) }
  scope :from_last_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :for_users, ->(user_ids) { where(user_id: user_ids) }

  def duration_in_seconds
    return nil unless clock_in && clock_out
    (clock_out - clock_in).to_i
  end

  def duration_in_hours
    duration = duration_in_seconds
    return nil unless duration
    duration / 3600.0
  end

  def completed?
    clock_out.present?
  end

  def in_progress?
    clock_in.present? && clock_out.blank?
  end

  private

  def clock_out_after_clock_in
    return unless clock_in && clock_out

    errors.add(:clock_out, "must be after clock in time") if clock_out <= clock_in
  end
end
