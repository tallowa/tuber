Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # Owner/Vehicle Management
  resources :vehicles do
    member do
      patch :toggle_ride_availability
      patch :toggle_rental_availability
    end
    resources :vehicle_availabilities, except: [:show]
    resources :ride_requests, only: [:index, :show, :update] do
      member do
        patch :accept
        patch :reject
        patch :complete
      end
    end
    resources :rental_bookings, only: [:index, :show, :update] do
      member do
        patch :confirm
        patch :reject
        patch :start_rental
        patch :end_rental
      end
    end
  end
  
  # Rider/Renter interfaces
  resources :ride_requests, only: [:new, :create, :show, :index]
  resources :rental_bookings, only: [:new, :create, :show, :index]
  
  # Search & Discovery
  get 'search', to: 'search#index'
  get 'search/vehicles', to: 'search#vehicles'
  get 'search/rides', to: 'search#rides'
  
  # User Profile & Dashboard
  get 'dashboard', to: 'dashboard#index'
  resources :users, only: [:show, :edit, :update]
end

