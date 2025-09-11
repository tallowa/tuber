class CreateVehicleAvailabilities < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicle_availabilities do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :availability_type # 'rides', 'rental', 'blocked', 'both'
      t.text :notes
      t.boolean :recurring, default: false
      t.string :recurring_pattern # 'weekly', 'daily', 'monthly'
      t.json :recurring_days # [1,2,3,4,5] for weekdays

      t.timestamps
    end

    add_index :vehicle_availabilities, [:start_time, :end_time]
  end
end
