class CreateRegularAttendees < ActiveRecord::Migration[8.0]
  def change
    create_table :regular_attendees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true

      t.timestamps
    end

    add_index :regular_attendees, [:user_id, :slot_id], unique: true
  end
end
