class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.references :reviewable, polymorphic: true, null: false # RideRequest or RentalBooking
      t.integer :rating, null: false # 1-5 stars
      t.text :comment
      t.string :review_type # 'driver_review', 'rider_review', 'owner_review', 'renter_review'

      t.timestamps
    end

    add_index :reviews, [:reviewer_id, :reviewee_id]
    add_index :reviews, [:reviewable_type, :reviewable_id]
  end
end
