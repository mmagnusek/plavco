class CancellationsController < ApplicationController
  before_action :set_slot

  # Optional: Uncomment to enforce authorization
  # load_and_authorize_resource

  def create
    week_start = Date.parse(params[:week_start]) || Date.current.beginning_of_week
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    dom_id = "#{week_start.strftime('%Y-%m-%d')}_slot_#{@slot.id}"

    @cancellation = @slot.cancellations.build(user:, week_start:)

    authorize! :create, @cancellation

    @cancellation.save!

    respond_to do |format|
      format.turbo_stream # { render turbo_stream: turbo_stream.replace(dom_id, partial: 'calendar/slot_detail', locals: { slot: @slot, current_week_start: week_start }) }
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: 'Slot cancelled successfully.' }
      format.json { render json: { success: true, message: 'Slot cancelled successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream # { render turbo_stream: turbo_stream.replace(dom_id, partial: 'calendar/slot_detail', locals: { slot: @slot, current_week_start: week_start }) }
      format.html { redirect_back fallback_location: calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def set_slot
    @slot = Slot.find(params[:id])
  end
end
