class RentalBooking < ApplicationRecord
  belongs_to :renter, class_name: 'User'
  belongs_to :vehicle
  has_one :owner, through: :vehicle, source: :owner
  has_many :reviews, as: :reviewable, dependent: :destroy

  validates :start_time, :end_time, presence: true
  validates :pickup_location, presence: true
  validates :status, inclusion: { 
    in: %w[pending confirmed active completed cancelled] 
  }
  validate :end_time_after_start_time

  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :active, -> { where(status: ['confirmed', 'active']) }
  scope :completed, -> { where(status: 'completed') }
  scope :active_during, ->(start_time, end_time) {
    active.where(
      "(start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)",
      start_time, start_time, end_time, end_time, start_time, end_time
    )
  }

  def duration_in_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(2)
  end

  def duration_in_days
    duration_in_hours / 24.0
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end
end
