class RemoveOldUniqueConstraintFromBookings < ActiveRecord::Migration[8.0]
  def up
    # Remove the old unique constraint that only used user_id and slot_id
    remove_index :bookings, [:user_id, :slot_id], name: 'index_bookings_on_user_id_and_slot_id'
  end

  def down
    # Restore the old unique constraint if needed
    add_index :bookings, [:user_id, :slot_id], unique: true, name: 'index_bookings_on_user_id_and_slot_id'
  end
end
