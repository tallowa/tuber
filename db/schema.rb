# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_11_080328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "rental_bookings", force: :cascade do |t|
    t.bigint "renter_id", null: false
    t.bigint "vehicle_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "actual_start_time"
    t.datetime "actual_end_time"
    t.string "pickup_location"
    t.string "return_location"
    t.decimal "pickup_latitude", precision: 10, scale: 6
    t.decimal "pickup_longitude", precision: 10, scale: 6
    t.decimal "return_latitude", precision: 10, scale: 6
    t.decimal "return_longitude", precision: 10, scale: 6
    t.text "purpose"
    t.integer "estimated_miles"
    t.integer "actual_miles"
    t.string "status", default: "pending"
    t.decimal "quoted_price", precision: 8, scale: 2
    t.decimal "final_price", precision: 8, scale: 2
    t.decimal "security_deposit", precision: 8, scale: 2
    t.text "special_requirements"
    t.text "owner_notes"
    t.text "renter_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["renter_id"], name: "index_rental_bookings_on_renter_id"
    t.index ["start_time", "end_time"], name: "index_rental_bookings_on_start_time_and_end_time"
    t.index ["status"], name: "index_rental_bookings_on_status"
    t.index ["vehicle_id"], name: "index_rental_bookings_on_vehicle_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "reviewer_id", null: false
    t.bigint "reviewee_id", null: false
    t.string "reviewable_type", null: false
    t.bigint "reviewable_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.string "review_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id", "reviewee_id"], name: "index_reviews_on_reviewer_id_and_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "ride_requests", force: :cascade do |t|
    t.bigint "rider_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "pickup_address"
    t.string "destination_address"
    t.decimal "pickup_latitude", precision: 10, scale: 6
    t.decimal "pickup_longitude", precision: 10, scale: 6
    t.decimal "destination_latitude", precision: 10, scale: 6
    t.decimal "destination_longitude", precision: 10, scale: 6
    t.datetime "requested_pickup_time"
    t.datetime "actual_pickup_time"
    t.datetime "actual_dropoff_time"
    t.integer "passenger_count", default: 1
    t.text "special_requests"
    t.string "status", default: "pending"
    t.decimal "quoted_price", precision: 8, scale: 2
    t.decimal "final_price", precision: 8, scale: 2
    t.text "driver_notes"
    t.text "rider_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rider_id"], name: "index_ride_requests_on_rider_id"
    t.index ["status"], name: "index_ride_requests_on_status"
    t.index ["vehicle_id"], name: "index_ride_requests_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.date "date_of_birth"
    t.string "driver_license_number"
    t.string "driver_license_state"
    t.string "background_check_status", default: "pending"
    t.string "verification_status", default: "unverified"
    t.decimal "rating_as_driver", precision: 3, scale: 2, default: "0.0"
    t.decimal "rating_as_renter", precision: 3, scale: 2, default: "0.0"
    t.integer "total_rides_given", default: 0
    t.integer "total_rentals_completed", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicle_availabilities", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "availability_type"
    t.text "notes"
    t.boolean "recurring", default: false
    t.string "recurring_pattern"
    t.json "recurring_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_time", "end_time"], name: "index_vehicle_availabilities_on_start_time_and_end_time"
    t.index ["vehicle_id"], name: "index_vehicle_availabilities_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "make"
    t.string "model"
    t.integer "year"
    t.string "color"
    t.string "license_plate"
    t.string "vin"
    t.integer "passenger_capacity"
    t.string "transmission"
    t.string "fuel_type"
    t.text "description"
    t.text "amenities"
    t.decimal "daily_rental_rate", precision: 8, scale: 2
    t.decimal "hourly_rental_rate", precision: 8, scale: 2
    t.decimal "per_mile_rate", precision: 8, scale: 2
    t.boolean "available_for_rides", default: true
    t.boolean "available_for_rentals", default: true
    t.boolean "active", default: true
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "current_location_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_vehicles_on_latitude_and_longitude"
    t.index ["owner_id"], name: "index_vehicles_on_owner_id"
  end

  add_foreign_key "rental_bookings", "users", column: "renter_id"
  add_foreign_key "rental_bookings", "vehicles"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "ride_requests", "users", column: "rider_id"
  add_foreign_key "ride_requests", "vehicles"
  add_foreign_key "vehicle_availabilities", "vehicles"
  add_foreign_key "vehicles", "users", column: "owner_id"
end
