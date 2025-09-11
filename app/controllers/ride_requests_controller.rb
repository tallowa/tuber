class RideRequestsController < ApplicationController
  before_action :set_ride_request, only: [:show, :update, :accept, :reject, :complete]
  before_action :set_vehicle, only: [:index, :accept, :reject, :complete]
  
  def index
    if params[:vehicle_id]
      # Vehicle owner viewing requests for their vehicle
      @vehicle = current_user.owned_vehicles.find(params[:vehicle_id])
      @ride_requests = @vehicle.ride_requests
                              .includes(:rider)
                              .order(created_at: :desc)
                              .page(params[:page])
    else
      # User viewing their own ride requests
      @ride_requests = current_user.ride_requests_as_rider
                                  .includes(:vehicle, :driver)
                                  .order(created_at: :desc)
                                  .page(params[:page])
    end
  end
  
  def show
  end
  
  def new
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    @ride_request = RideRequest.new
    
    # Pre-fill from search params
    if params[:pickup_address].present?
      @ride_request.pickup_address = params[:pickup_address]
    end
    if params[:destination_address].present?
      @ride_request.destination_address = params[:destination_address]
    end
  end
  
  def create
    @ride_request = RideRequest.new(ride_request_params)
    @ride_request.rider = current_user
    
    # Calculate pricing
    if @ride_request.vehicle.present?
      @ride_request.quoted_price = calculate_ride_price(@ride_request)
    end
    
    if @ride_request.save
      # Notify vehicle owner
      RideRequestNotificationJob.perform_later(@ride_request)
      redirect_to @ride_request, notice: 'Ride request submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def accept
    @ride_request.update(status: 'accepted')
    redirect_to vehicle_ride_request_path(@vehicle, @ride_request),
                notice: 'Ride request accepted!'
  end
  
  def reject
    @ride_request.update(status: 'cancelled')
    redirect_to vehicle_ride_request_path(@vehicle, @ride_request),
                notice: 'Ride request declined.'
  end
  
  def complete
    @ride_request.update(
      status: 'completed',
      actual_dropoff_time: Time.current,
      final_price: @ride_request.quoted_price
    )
    redirect_to vehicle_ride_request_path(@vehicle, @ride_request),
                notice: 'Ride completed!'
  end
  
  private
  
  def set_ride_request
    @ride_request = RideRequest.find(params[:id])
  end
  
  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
  end
  
  def ride_request_params
    params.require(:ride_request).permit(:vehicle_id, :pickup_address, :destination_address,
                                        :requested_pickup_time, :passenger_count, 
                                        :special_requests)
  end
  
  def calculate_ride_price(ride_request)
    # Basic pricing calculation - would integrate with mapping service for real distance
    base_price = ride_request.vehicle.per_mile_rate * 10 # Assume 10 miles
    time_price = ride_request.vehicle.hourly_rental_rate * 0.5 # Assume 30 minutes
    
    total = base_price + time_price
    total * ride_request.passenger_count # Charge per passenger
  end
end
