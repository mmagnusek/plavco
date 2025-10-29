class AddCancellationReferenceToBookings < ActiveRecord::Migration[8.0]
  def change
    add_reference :bookings, :cancelled_from, null: true, foreign_key: { to_table: :cancellations }
  end
end
