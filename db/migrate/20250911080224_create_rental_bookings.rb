class CreateRentalBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :rental_bookings do |t|
      t.references :renter, null: false, foreign_key: { to_table: :users }
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :actual_start_time
      t.datetime :actual_end_time
      t.string :pickup_location
      t.string :return_location
      t.decimal :pickup_latitude, precision: 10, scale: 6
      t.decimal :pickup_longitude, precision: 10, scale: 6
      t.decimal :return_latitude, precision: 10, scale: 6
      t.decimal :return_longitude, precision: 10, scale: 6
      t.text :purpose # business, leisure, moving, etc.
      t.integer :estimated_miles
      t.integer :actual_miles
      t.string :status, default: 'pending' # pending, confirmed, active, completed, cancelled
      t.decimal :quoted_price, precision: 8, scale: 2
      t.decimal :final_price, precision: 8, scale: 2
      t.decimal :security_deposit, precision: 8, scale: 2
      t.text :special_requirements
      t.text :owner_notes
      t.text :renter_notes

      t.timestamps
    end

    add_index :rental_bookings, :status
    add_index :rental_bookings, [:start_time, :end_time]
  end
end
