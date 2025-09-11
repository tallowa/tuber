class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :make
      t.string :model
      t.integer :year
      t.string :color
      t.string :license_plate
      t.string :vin
      t.integer :passenger_capacity
      t.string :transmission # manual, automatic
      t.string :fuel_type # gas, electric, hybrid
      t.text :description
      t.text :amenities
      t.decimal :daily_rental_rate, precision: 8, scale: 2
      t.decimal :hourly_rental_rate, precision: 8, scale: 2
      t.decimal :per_mile_rate, precision: 8, scale: 2
      t.boolean :available_for_rides, default: true
      t.boolean :available_for_rentals, default: true
      t.boolean :active, default: true
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :current_location_address

      t.timestamps
    end

    add_index :vehicles, [:latitude, :longitude]
  end
end
