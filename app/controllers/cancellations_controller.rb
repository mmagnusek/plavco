class CancellationsController < ApplicationController
  before_action :set_slot
  before_action :set_user

  # Optional: Uncomment to enforce authorization
  # load_and_authorize_resource

  def create
    week_start = params[:week_start] || Date.current.beginning_of_week

    @cancellation = @slot.cancellations.build(user: @user, week_start: week_start)

    authorize! :create, @cancellation

    @cancellation.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Slot cancelled successfully.' }
      format.json { render json: { success: true, message: 'Slot cancelled successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
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
