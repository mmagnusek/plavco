class CreateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :slots do |t|
      t.integer :day_of_week, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.integer :max_participants, null: false, default: 1

      t.timestamps
    end

    add_index :slots, [:day_of_week, :starts_at], unique: true
  end
end
