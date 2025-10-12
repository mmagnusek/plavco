class BookingsController < ApplicationController
  before_action :set_slot
  before_action :set_user

  # Optional: Uncomment to enforce authorization
  # load_and_authorize_resource

  def create
    authorize! :create, Booking

    week_start = params[:week_start] || Date.current.beginning_of_week

    @booking = Booking.find_or_create_by!(
      user: @user,
      slot: @slot,
      week_start: week_start
    )

    respond_to do |format|
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Slot booked successfully.' }
      format.json { render json: { success: true, message: 'Slot booked successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { redirect_back fallback_location: calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    week_start = params[:week_start] || Date.current.beginning_of_week
    @booking = Booking.find_by(user: @user, slot: @slot, week_start: week_start)

    authorize! :destroy, @booking if @booking

    if @booking
      @booking.destroy!
      respond_to do |format|
        format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Booking removed successfully.' }
        format.json { render json: { success: true, message: 'Booking removed successfully.' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: calendar_index_path, alert: 'No booking found.' }
        format.json { render json: { success: false, message: 'No booking found.' }, status: :not_found }
      end
    end
  end

  private

  def set_slot
    @slot = Slot.find(params[:slot_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
