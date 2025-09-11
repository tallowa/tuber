class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewee, class_name: 'User'
  belongs_to :reviewable, polymorphic: true

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :review_type, inclusion: { 
    in: %w[driver_review rider_review owner_review renter_review] 
  }
  validates :comment, presence: true, length: { minimum: 10 }

  scope :for_drivers, -> { where(review_type: 'driver_review') }
  scope :for_riders, -> { where(review_type: 'rider_review') }
  scope :for_owners, -> { where(review_type: 'owner_review') }
  scope :for_renters, -> { where(review_type: 'renter_review') }
end
