class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :date_of_birth
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :phone, :date_of_birth
    ])
  end
  
  def ensure_vehicle_owner
    unless @vehicle.owner == current_user
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
