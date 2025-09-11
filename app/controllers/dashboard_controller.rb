class DashboardController < ApplicationController
  def index
    @my_vehicles = current_user.owned_vehicles.active.includes(:photos_attachments)
    
    # Recent ride requests for my vehicles
    @recent_ride_requests = RideRequest.joins(:vehicle)
                                      .where(vehicles: { owner_id: current_user.id })
                                      .includes(:rider, :vehicle)
                                      .order(created_at: :desc)
                                      .limit(5)
    
    # Recent rental bookings for my vehicles  
    @recent_rental_bookings = RentalBooking.joins(:vehicle)
                                          .where(vehicles: { owner_id: current_user.id })
                                          .includes(:renter, :vehicle)
                                          .order(created_at: :desc)
                                          .limit(5)
    
    # My ride requests (as a rider)
    @my_ride_requests = current_user.ride_requests_as_rider
                                   .includes(:vehicle, :driver)
                                   .order(created_at: :desc)
                                   .limit(5)
    
    # My rental bookings (as a renter)
    @my_rental_bookings = current_user.rental_bookings_as_renter
                                     .includes(:vehicle, :owner)
                                     .order(created_at: :desc)
                                     .limit(5)
    
    # Revenue summary for vehicle owners
    if @my_vehicles.any?
      @revenue_summary = calculate_revenue_summary
    end
  end
  
  private
  
  def calculate_revenue_summary
    last_30_days = 30.days.ago..Time.current
    
    ride_revenue = RideRequest.joins(:vehicle)
                             .where(vehicles: { owner_id: current_user.id })
                             .where(status: 'completed', created_at: last_30_days)
                             .sum(:final_price) || 0
    
    rental_revenue = RentalBooking.joins(:vehicle)
                                 .where(vehicles: { owner_id: current_user.id })
                                 .where(status: 'completed', created_at: last_30_days)
                                 .sum(:final_price) || 0
    
    {
      total_revenue: ride_revenue + rental_revenue,
      ride_revenue: ride_revenue,
      rental_revenue: rental_revenue,
      period: "Last 30 days"
    }
  end
end
