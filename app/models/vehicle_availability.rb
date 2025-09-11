class VehicleAvailability < ApplicationRecord
  belongs_to :vehicle

  validates :start_time, :end_time, :availability_type, presence: true
  validates :availability_type, inclusion: { 
    in: %w[rides rental blocked both] 
  }
  validate :end_time_after_start_time

  scope :for_rides, -> { where(availability_type: ['rides', 'both']) }
  scope :for_rentals, -> { where(availability_type: ['rental', 'both']) }
  scope :blocked, -> { where(availability_type: 'blocked') }
  scope :during, ->(start_time, end_time) {
    where(
      "(start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)",
      start_time, start_time, end_time, end_time, start_time, end_time
    )
  }

  def available_for_rides?
    availability_type.in?(['rides', 'both'])
  end

  def available_for_rentals?
    availability_type.in?(['rental', 'both'])
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end
end
