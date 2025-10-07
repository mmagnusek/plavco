class AddWeekStartToBookings < ActiveRecord::Migration[8.0]
  def up
    # First add the column as nullable
    add_column :bookings, :week_start, :date

    # Set default week_start for existing bookings (current week)
    Booking.update_all(week_start: Date.current.beginning_of_week)

    # Make it non-nullable
    change_column_null :bookings, :week_start, false

    # Add indexes
    add_index :bookings, [:user_id, :slot_id, :week_start], unique: true, name: 'index_bookings_unique_weekly'
    add_index :bookings, [:slot_id, :week_start]
  end

  def down
    remove_index :bookings, name: 'index_bookings_unique_weekly'
    remove_index :bookings, [:slot_id, :week_start]
    remove_column :bookings, :week_start
  end
end
