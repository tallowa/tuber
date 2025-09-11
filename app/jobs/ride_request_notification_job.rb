class RideRequestNotificationJob < ApplicationJob
  def perform(ride_request)
    # Send notification to vehicle owner
    # Could use email, SMS, push notification, etc.
    Rails.logger.info "Ride request notification sent for request ##{ride_request.id}"
  end
end
