class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :owned_vehicles, class_name: 'Vehicle', foreign_key: 'owner_id', dependent: :destroy
  has_many :ride_requests_as_rider, class_name: 'RideRequest', foreign_key: 'rider_id'
  has_many :ride_requests_as_driver, through: :owned_vehicles, source: :ride_requests
  has_many :rental_bookings_as_renter, class_name: 'RentalBooking', foreign_key: 'renter_id'
  has_many :rental_bookings_as_owner, through: :owned_vehicles, source: :rental_bookings
  has_many :reviews_given, class_name: 'Review', foreign_key: 'reviewer_id'
  has_many :reviews_received, class_name: 'Review', foreign_key: 'reviewee_id'
  has_one_attached :avatar
  has_one_attached :driver_license_photo

  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :rating_as_driver, :rating_as_renter, 
           numericality: { in: 0.0..5.0 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_drive?
    verified? && background_check_approved?
  end

  def can_rent_vehicles?
    verified? && (rating_as_renter >= 3.0 || total_rentals_completed == 0)
  end

  def verified?
    verification_status == 'verified'
  end

  def background_check_approved?
    background_check_status == 'approved'
  end

  def average_rating_as_driver
    return 0.0 if total_rides_given.zero?
    rating_as_driver
  end

  def average_rating_as_renter
    return 0.0 if total_rentals_completed.zero?
    rating_as_renter
  end
end





