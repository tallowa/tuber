class SearchController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :vehicles, :rides]
  
  def index
    # Main search page
  end
  
  def vehicles
    @search_params = search_params
    @vehicles = Vehicle.active.includes(:owner, :photos_attachments)
    
    # Location-based search
    if @search_params[:location].present?
      coordinates = Geocoder.coordinates(@search_params[:location])
      if coordinates
        @vehicles = @vehicles.near(coordinates, 25) # 25 mile radius
      end
    end
    
    # Date availability filter
    if @search_params[:start_time].present? && @search_params[:end_time].present?
      start_time = Time.parse(@search_params[:start_time])
      end_time = Time.parse(@search_params[:end_time])
      
      case @search_params[:search_type]
      when 'rental'
        @vehicles = @vehicles.available_for_rentals
                           .select { |v| v.available_for_rental?(start_time, end_time) }
      when 'ride'
        @vehicles = @vehicles.available_for_rides
                           .select { |v| v.available_for_ride?(start_time, end_time) }
      end
    else
      # Default to showing rental availability
      @vehicles = @vehicles.available_for_rentals
    end
    
    # Vehicle type filters
    if @search_params[:passenger_capacity].present?
      @vehicles = @vehicles.where('passenger_capacity >= ?', @search_params[:passenger_capacity])
    end
    
    if @search_params[:fuel_type].present?
      @vehicles = @vehicles.where(fuel_type: @search_params[:fuel_type])
    end
    
    # Price range filter
    if @search_params[:max_daily_rate].present?
      @vehicles = @vehicles.where('daily_rental_rate <= ?', @search_params[:max_daily_rate])
    end
    
    @vehicles = @vehicles.limit(20) # Limit results for performance
  end
  
  def rides
    # Find available rides (vehicles with owners willing to drive)
    @search_params = search_params
    @available_rides = []
    
    if @search_params[:pickup_location].present? && @search_params[:destination].present?
      pickup_coords = Geocoder.coordinates(@search_params[:pickup_location])
      
      if pickup_coords
        nearby_vehicles = Vehicle.active
                                .available_for_rides
                                .near(pickup_coords, 15) # 15 mile radius
                                .includes(:owner)
        
        @available_rides = nearby_vehicles.map do |vehicle|
          {
            vehicle: vehicle,
            estimated_price: estimate_ride_price(vehicle, @search_params),
            estimated_pickup_time: "5-15 minutes" # Would calculate based on distance
          }
        end
      end
    end
  end
  
  private
  
  def search_params
    params.permit(:location, :pickup_location, :destination, :start_time, :end_time,
                  :search_type, :passenger_capacity, :fuel_type, :max_daily_rate,
                  :requested_pickup_time)
  end
  
  def estimate_ride_price(vehicle, search_params)
    # Basic estimation - would integrate with mapping API for real calculation
    estimated_distance = 10 # miles
    estimated_time = 0.5 # hours
    
    distance_cost = vehicle.per_mile_rate * estimated_distance
    time_cost = vehicle.hourly_rental_rate * estimated_time
    
    distance_cost + time_cost
  end
end
