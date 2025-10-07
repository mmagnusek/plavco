class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.date :week_start, null: false
      t.boolean :attending, null: false, default: true

      t.timestamps
    end

    add_index :attendances, [:user_id, :slot_id, :week_start], unique: true, name: 'index_attendances_unique_weekly'
    add_index :attendances, [:slot_id, :week_start]
  end
end
