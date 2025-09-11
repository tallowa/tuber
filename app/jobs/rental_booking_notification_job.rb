class RentalBookingNotificationJob < ApplicationJob
  def perform(rental_booking)
    # Send notification to vehicle owner
    # Could use email, SMS, push notification, etc.
    Rails.logger.info "Rental booking notification sent for booking ##{rental_booking.id}"
  end
end
