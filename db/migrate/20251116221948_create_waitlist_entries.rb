class CreateWaitlistEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :waitlist_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.date :week_start, null: false

      t.timestamps
    end

    add_index :waitlist_entries, [:user_id, :slot_id, :week_start], unique: true, name: 'index_waitlist_entries_unique_weekly'
    add_index :waitlist_entries, [:slot_id, :week_start]
  end
end
