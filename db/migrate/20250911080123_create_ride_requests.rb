class CreateRideRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :ride_requests do |t|
      t.references :rider, null: false, foreign_key: { to_table: :users }
      t.references :vehicle, null: false, foreign_key: true
      t.string :pickup_address
      t.string :destination_address
      t.decimal :pickup_latitude, precision: 10, scale: 6
      t.decimal :pickup_longitude, precision: 10, scale: 6
      t.decimal :destination_latitude, precision: 10, scale: 6
      t.decimal :destination_longitude, precision: 10, scale: 6
      t.datetime :requested_pickup_time
      t.datetime :actual_pickup_time
      t.datetime :actual_dropoff_time
      t.integer :passenger_count, default: 1
      t.text :special_requests
      t.string :status, default: 'pending' # pending, accepted, in_progress, completed, cancelled
      t.decimal :quoted_price, precision: 8, scale: 2
      t.decimal :final_price, precision: 8, scale: 2
      t.text :driver_notes
      t.text :rider_notes

      t.timestamps
    end

    add_index :ride_requests, :status
  end
end
