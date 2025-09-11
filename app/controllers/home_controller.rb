class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      @featured_vehicles = Vehicle.active
                                 .includes(:owner, photos_attachments: :blob)
                                 .limit(6)
      @recent_activity = {
        total_vehicles: Vehicle.active.count,
        total_rides: RideRequest.completed.count,
        total_rentals: RentalBooking.completed.count
      }
    end
  end
end
