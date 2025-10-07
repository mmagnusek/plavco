class CreateCancellations < ActiveRecord::Migration[8.0]
  def change
    create_table :cancellations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.date :week_start, null: false

      t.timestamps
    end

    add_index :cancellations, [:user_id, :slot_id, :week_start], unique: true, name: 'index_cancellations_unique_weekly'
    add_index :cancellations, [:slot_id, :week_start]
  end
end
