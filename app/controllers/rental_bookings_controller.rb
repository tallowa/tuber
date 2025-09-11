class RentalBookingsController < ApplicationController
  before_action :set_rental_booking, only: [:show, :update, :confirm, :reject, 
                                           :start_rental, :end_rental]
  before_action :set_vehicle, only: [:index, :confirm, :reject, :start_rental, :end_rental]
  
  def index
    if params[:vehicle_id]
      # Vehicle owner viewing bookings for their vehicle
      @vehicle = current_user.owned_vehicles.find(params[:vehicle_id])
      @rental_bookings = @vehicle.rental_bookings
                                .includes(:renter)
                                .order(created_at: :desc)
                                .page(params[:page])
    else
      # User viewing their own rental bookings
      @rental_bookings = current_user.rental_bookings_as_renter
                                    .includes(:vehicle, :owner)
                                    .order(created_at: :desc)
                                    .page(params[:page])
    end
  end
  
  def show
  end
  
  def new
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    @rental_booking = RentalBooking.new
    
    # Pre-fill from search params
    if params[:start_time].present?
      @rental_booking.start_time = Time.parse(params[:start_time])
    end
    if params[:end_time].present?
      @rental_booking.end_time = Time.parse(params[:end_time])
    end
  end
  
  def create
    @rental_booking = RentalBooking.new(rental_booking_params)
    @rental_booking.renter = current_user
    
    # Calculate pricing
    if @rental_booking.vehicle.present? && @rental_booking.start_time && @rental_booking.end_time
      @rental_booking.quoted_price = calculate_rental_price(@rental_booking)
      @rental_booking.security_deposit = @rental_booking.quoted_price * 0.2 # 20% deposit
    end
    
    if @rental_booking.save
      # Notify vehicle owner
      RentalBookingNotificationJob.perform_later(@rental_booking)
      redirect_to @rental_booking, notice: 'Rental booking submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def confirm
    @rental_booking.update(status: 'confirmed')
    redirect_to vehicle_rental_booking_path(@vehicle, @rental_booking),
                notice: 'Rental booking confirmed!'
  end
  
  def reject
    @rental_booking.update(status: 'cancelled')
    redirect_to vehicle_rental_booking_path(@vehicle, @rental_booking),
                notice: 'Rental booking declined.'
  end
  
  def start_rental
    @rental_booking.update(
      status: 'active',
      actual_start_time: Time.current
    )
    redirect_to vehicle_rental_booking_path(@vehicle, @rental_booking),
                notice: 'Rental started!'
  end
  
  def end_rental
    @rental_booking.update(
      status: 'completed',
      actual_end_time: Time.current,
      final_price: @rental_booking.quoted_price
    )
    redirect_to vehicle_rental_booking_path(@vehicle, @rental_booking),
                notice: 'Rental completed!'
  end
  
  private
  
  def set_rental_booking
    @rental_booking = RentalBooking.find(params[:id])
  end
  
  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
  end
  
  def rental_booking_params
    params.require(:rental_booking).permit(:vehicle_id, :start_time, :end_time,
                                          :pickup_location, :return_location,
                                          :purpose, :estimated_miles,
                                          :special_requirements)
  end
  
  def calculate_rental_price(rental_booking)
    duration_hours = rental_booking.duration_in_hours
    vehicle = rental_booking.vehicle
    
    if duration_hours >= 24
      # Use daily rate for full day rentals
      days = rental_booking.duration_in_days
      vehicle.daily_rental_rate * days
    else
      # Use hourly rate for short rentals
      vehicle.hourly_rental_rate * duration_hours
    end
  end
end
