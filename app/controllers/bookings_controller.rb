class BookingsController < ApplicationController
  before_action :set_slot, except: [:destroy]

  # Optional: Uncomment to enforce authorization
  # load_and_authorize_resource

  def create
    authorize! :create, Booking

    week_start = Date.parse(params[:week_start]) || Date.current.beginning_of_week
    user = params[:user_id] ? User.find(params[:user_id]) : current_user

    @booking = Booking.find_or_create_by!(
      user: user,
      slot: @slot,
      week_start: week_start
    )

    if params[:cancelled_slot_id].present?
      Slot.find(params[:cancelled_slot_id]).cancellations.create!(
        user: user,
        week_start: week_start,
        booking: @booking
      )
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Booking created successfully.' }
      format.json { render json: { success: true, message: 'Booking created successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
    end
  end

  def update
    @booking = Booking.find(params[:id])
    @booking.update!(slot: @slot)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: calendar_index_path(week: @booking.week_start), notice: 'Successfully swapped.' }
      format.json { render json: { success: true, message: 'Successfully swapped.' } }
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    week_start = @booking.week_start

    authorize! :destroy, @booking if @booking

    if @booking
      @booking.destroy!
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Booking removed successfully.' }
        format.json { render json: { success: true, message: 'Booking removed successfully.' } }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: calendar_index_path, alert: 'No booking found.' }
        format.json { render json: { success: false, message: 'No booking found.' }, status: :not_found }
      end
    end
  end


  private

  def set_slot
    @slot = Slot.find(params[:slot_id])
  end
end
