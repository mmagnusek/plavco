class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.datetime :booked_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :bookings, [:user_id, :slot_id], unique: true
  end
end
