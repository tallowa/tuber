class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy, 
                                    :toggle_ride_availability, :toggle_rental_availability]
  before_action :ensure_vehicle_owner, only: [:edit, :update, :destroy, 
                                             :toggle_ride_availability, :toggle_rental_availability]
  
  def index
    @vehicles = current_user.owned_vehicles.active.includes(:photos_attachments)
  end
  
  def show
    @recent_rides = @vehicle.ride_requests
                           .includes(:rider)
                           .order(created_at: :desc)
                           .limit(10)
    
    @recent_rentals = @vehicle.rental_bookings
                             .includes(:renter)
                             .order(created_at: :desc)
                             .limit(10)
    
    @vehicle_stats = {
      total_rides: @vehicle.ride_requests.completed.count,
      total_rentals: @vehicle.rental_bookings.completed.count,
      utilization_rate: @vehicle.current_utilization_rate,
      total_earnings: calculate_vehicle_earnings(@vehicle)
    }
  end
  
  def new
    @vehicle = current_user.owned_vehicles.build
  end
  
  def create
    @vehicle = current_user.owned_vehicles.build(vehicle_params)
    
    if @vehicle.save
      redirect_to @vehicle, notice: 'Vehicle was successfully added to your fleet!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: 'Vehicle was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @vehicle.update(active: false)
    redirect_to vehicles_path, notice: 'Vehicle has been deactivated.'
  end
  
  def toggle_ride_availability
    @vehicle.update(available_for_rides: !@vehicle.available_for_rides?)
    status = @vehicle.available_for_rides? ? 'enabled' : 'disabled'
    redirect_to @vehicle, notice: "Ride sharing has been #{status} for this vehicle."
  end
  
  def toggle_rental_availability
    @vehicle.update(available_for_rentals: !@vehicle.available_for_rentals?)
    status = @vehicle.available_for_rentals? ? 'enabled' : 'disabled'
    redirect_to @vehicle, notice: "Vehicle rentals have been #{status} for this vehicle."
  end
  
  private
  
  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end
  
  def vehicle_params
    params.require(:vehicle).permit(:make, :model, :year, :color, :license_plate, :vin,
                                   :passenger_capacity, :transmission, :fuel_type,
                                   :description, :amenities, :daily_rental_rate,
                                   :hourly_rental_rate, :per_mile_rate,
                                   :available_for_rides, :available_for_rentals,
                                   :current_location_address, photos: [])
  end
  
  def calculate_vehicle_earnings(vehicle)
    ride_earnings = vehicle.ride_requests.completed.sum(:final_price) || 0
    rental_earnings = vehicle.rental_bookings.completed.sum(:final_price) || 0
    ride_earnings + rental_earnings
  end
end
