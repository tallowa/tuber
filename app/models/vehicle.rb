class Vehicle < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :vehicle_availabilities, dependent: :destroy
  has_many :ride_requests, dependent: :destroy
  has_many :rental_bookings, dependent: :destroy
  has_many_attached :photos

  validates :make, :model, :year, :color, :license_plate, presence: true
  validates :passenger_capacity, presence: true, 
           numericality: { greater_than: 0, less_than: 9 }
  validates :year, numericality: { 
    greater_than: 2010, 
    less_than_or_equal_to: Date.current.year + 1 
  }
  validates :daily_rental_rate, :hourly_rental_rate, :per_mile_rate,
           presence: true, numericality: { greater_than: 0 }

  geocoded_by :current_location_address, latitude: :latitude, longitude: :longitude
  after_validation :geocode, if: :current_location_address_changed?

  scope :active, -> { where(active: true) }
  scope :available_for_rides, -> { where(available_for_rides: true) }
  scope :available_for_rentals, -> { where(available_for_rentals: true) }
  scope :near_location, ->(lat, lng, radius) { 
    near([lat, lng], radius) 
  }

  def display_name
    "#{year} #{make} #{model}"
  end

  def available_for_ride?(start_time, end_time)
    return false unless available_for_rides? && active?
    
    # Check if there are any conflicting bookings
    conflicting_rentals = rental_bookings.active_during(start_time, end_time)
    conflicting_rides = ride_requests.active_during(start_time, end_time)
    blocked_times = vehicle_availabilities.blocked_during(start_time, end_time)
    
    conflicting_rentals.empty? && conflicting_rides.empty? && blocked_times.empty?
  end

  def available_for_rental?(start_time, end_time)
    return false unless available_for_rentals? && active?
    
    # Check if there are any conflicting bookings
    conflicting_rentals = rental_bookings.active_during(start_time, end_time)
    conflicting_rides = ride_requests.active_during(start_time, end_time)
    blocked_times = vehicle_availabilities.blocked_during(start_time, end_time)
    
    conflicting_rentals.empty? && conflicting_rides.empty? && blocked_times.empty?
  end

  def current_utilization_rate
    # Calculate what percentage of time vehicle is earning money
    total_hours_last_month = 30 * 24
    earning_hours = calculate_earning_hours_last_month
    
    (earning_hours.to_f / total_hours_last_month * 100).round(1)
  end

  private

  def calculate_earning_hours_last_month
    # Calculate hours spent on rides + rentals in last 30 days
    start_date = 30.days.ago
    end_date = Time.current
    
    ride_hours = ride_requests.completed
                             .where(created_at: start_date..end_date)
                             .sum { |ride| ride.duration_in_hours }
    
    rental_hours = rental_bookings.completed
                                 .where(created_at: start_date..end_date)
                                 .sum { |rental| rental.duration_in_hours }
    
    ride_hours + rental_hours
  end
end
