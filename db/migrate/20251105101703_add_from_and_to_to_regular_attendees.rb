class AddFromAndToToRegularAttendees < ActiveRecord::Migration[8.0]
  def change
    add_column :regular_attendees, :from, :date
    add_column :regular_attendees, :to, :date

    remove_index :regular_attendees, [:user_id, :slot_id], unique: true
    add_index :regular_attendees, [:user_id, :slot_id, :from, :to], unique: true

    RegularAttendee.all.each do |regular_attendee|
      regular_attendee.update(from: regular_attendee.created_at.to_date)
    end

    change_column_null :regular_attendees, :from, false
  end
end
