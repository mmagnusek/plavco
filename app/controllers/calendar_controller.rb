class CalendarController < ApplicationController
  def index
    # Handle week navigation
    if params[:week].present?
      begin
        base_date = Date.parse(params[:week])
        @current_week_start = base_date.beginning_of_week
      rescue ArgumentError
        @current_week_start = Date.current.beginning_of_week
      end
    else
      @current_week_start = Date.current.beginning_of_week
    end

    @current_week_end = @current_week_start.end_of_week

    # Get all slots for the current week
    @slots_by_day = {}
    (0..6).each do |day_of_week|
      @slots_by_day[day_of_week] = Slot.where(day_of_week: day_of_week).order(:starts_at)
    end

    # Get all users for booking display
    @users = User.all

    # Get current week's cancellations
    @cancellations = Cancellation.for_week(@current_week_start).includes(:user, :slot)

    # Get current bookings for the week (temporary bookings)
    @bookings = Booking.joins(:slot).where(
      'slots.day_of_week IN (?)',
      (@current_week_start.wday..@current_week_end.wday).to_a
    ).includes(:user, :slot)
  end

  private

  def prev_week_url
    calendar_index_path(week: (@current_week_start - 1.week).strftime('%Y-%m-%d'))
  end

  def next_week_url
    calendar_index_path(week: (@current_week_start + 1.week).strftime('%Y-%m-%d'))
  end

  def current_week_url
    calendar_index_path(week: @current_week_start.strftime('%Y-%m-%d'))
  end

  helper_method :prev_week_url, :next_week_url, :current_week_url
end
