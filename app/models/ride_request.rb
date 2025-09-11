class RideRequest < ApplicationRecord
  belongs_to :rider, class_name: 'User'
  belongs_to :vehicle
  has_one :driver, through: :vehicle, source: :owner
  has_many :reviews, as: :reviewable, dependent: :destroy

  validates :pickup_address, :destination_address, presence: true
  validates :requested_pickup_time, :passenger_count, presence: true
  validates :passenger_count, numericality: { greater_than: 0 }
  validates :status, inclusion: { 
    in: %w[pending accepted in_progress completed cancelled] 
  }

  geocoded_by :pickup_address, 
             latitude: :pickup_latitude, 
             longitude: :pickup_longitude
  geocoded_by :destination_address, 
             latitude: :destination_latitude, 
             longitude: :destination_longitude

  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where(status: ['accepted', 'in_progress']) }
  scope :completed, -> { where(status: 'completed') }
  scope :active_during, ->(start_time, end_time) {
    active.where(
      "(requested_pickup_time <= ? AND requested_pickup_time + INTERVAL '2 hours' >= ?)",
      end_time, start_time
    )
  }

  def duration_in_hours
    return 0 unless actual_pickup_time && actual_dropoff_time
    ((actual_dropoff_time - actual_pickup_time) / 1.hour).round(2)
  end

  def estimated_duration_minutes
    # This would integrate with mapping service for real estimates
    60 # placeholder
  end
end
