class CalendarController < ApplicationController
  def index
    @current_week_start = Date.current.beginning_of_week
    @current_week_end = Date.current.end_of_week

    # Get all slots for the current week
    @slots_by_day = {}
    (0..6).each do |day_of_week|
      @slots_by_day[day_of_week] = Slot.where(day_of_week: day_of_week).order(:starts_at)
    end

    # Get all users for booking display
    @users = User.all

    # Get current week's attendance records
    @attendances = Attendance.for_week(@current_week_start).includes(:user, :slot)

    # Get current bookings for the week (temporary bookings)
    @bookings = Booking.joins(:slot).where(
      'slots.day_of_week IN (?)',
      (@current_week_start.wday..@current_week_end.wday).to_a
    ).includes(:user, :slot)
  end
end
