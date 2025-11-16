class WaitlistEntriesController < ApplicationController
  before_action :set_slot, except: [:destroy]

  def create
    week_start = Date.parse(params[:week_start]) || Date.current.beginning_of_week
    @slot.waitlist_entries.create(user: current_user, week_start: week_start)
    dom_id = "#{week_start.strftime('%Y-%m-%d')}_slot_#{@slot.id}"

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id, partial: 'calendar/slot_detail', locals: { slot: @slot, current_week_start: week_start }) }
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: t('flashes.waiting_list.created') }
      format.json { render json: { success: true, message: t('flashes.waiting_list.created') } }
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: calendar_index_path, alert: e.message
  end

  def destroy
    waitlist_entry = WaitlistEntry.find(params[:id])

    authorize! :destroy, waitlist_entry

    week_start = waitlist_entry.week_start
    slot = waitlist_entry.slot
    dom_id = "#{week_start.strftime('%Y-%m-%d')}_slot_#{slot.id}"

    waitlist_entry.destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id, partial: 'calendar/slot_detail', locals: { slot: slot, current_week_start: week_start }) }
      format.html { redirect_back fallback_location: calendar_index_path(week: week_start), notice: t('flashes.waiting_list.removed') }
      format.json { render json: { success: true, message: t('flashes.waiting_list.removed') } }
    end
  end

  private

  def set_slot
    @slot = Slot.find(params[:slot_id])
  end
end
