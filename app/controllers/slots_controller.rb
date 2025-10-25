class SlotsController < ApplicationController
  before_action :require_authentication
  before_action :set_slot

  def refresh
    week_start = Date.parse(params[:week_start]) || Date.current.beginning_of_week
    dom_id = "#{week_start.strftime('%Y-%m-%d')}_slot_#{@slot.id}"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(dom_id, partial: 'calendar/slot_detail', locals: { slot: @slot, current_week_start: week_start })
      end
      format.html { redirect_to calendar_index_path(week: week_start) }
    end
  end

  private

  def set_slot
    @slot = Slot.find(params[:id])
  end
end
