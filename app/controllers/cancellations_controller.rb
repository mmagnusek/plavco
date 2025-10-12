class CancellationsController < ApplicationController
  before_action :set_slot
  before_action :set_user

  # Optional: Uncomment to enforce authorization
  # load_and_authorize_resource

  def create
    authorize! :create, Cancellation.new(user: @user)

    week_start = params[:week_start] || Date.current.beginning_of_week

    @cancellation = Cancellation.find_or_create_by!(
      user: @user,
      slot: @slot,
      week_start: week_start
    )

    respond_to do |format|
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Slot cancelled successfully.' }
      format.json { render json: { success: true, message: 'Slot cancelled successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { redirect_back fallback_location: calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    week_start = params[:week_start] || Date.current.beginning_of_week

    @cancellation = Cancellation.find_by(
      user: @user,
      slot: @slot,
      week_start: week_start
    )

    authorize! :destroy, @cancellation if @cancellation

    if @cancellation
      @cancellation.destroy!
      respond_to do |format|
        format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Slot restored successfully.' }
        format.json { render json: { success: true, message: 'Slot restored successfully.' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: calendar_index_path, alert: 'No cancellation found.' }
        format.json { render json: { success: false, message: 'No cancellation found.' }, status: :not_found }
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
