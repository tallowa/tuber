class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :driver_license_number, :string
    add_column :users, :driver_license_state, :string
    add_column :users, :background_check_status, :string, default: 'pending'
    add_column :users, :verification_status, :string, default: 'unverified'
    add_column :users, :rating_as_driver, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :users, :rating_as_renter, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :users, :total_rides_given, :integer, default: 0
    add_column :users, :total_rentals_completed, :integer, default: 0
  end
end
