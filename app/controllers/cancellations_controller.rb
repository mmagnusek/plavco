class CancellationsController < ApplicationController
  before_action :set_slot
  before_action :set_user

  def create
    @cancellation = Cancellation.find_or_create_by!(
      user: @user,
      slot: @slot,
      week_start: Date.current.beginning_of_week
    )

    respond_to do |format|
      format.html { redirect_to calendar_index_path, notice: 'Cancellation created successfully.' }
      format.json { render json: { success: true, message: 'Cancellation created successfully.' } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { redirect_to calendar_index_path, alert: e.message }
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    @cancellation = Cancellation.find_by(
      user: @user,
      slot: @slot,
      week_start: Date.current.beginning_of_week
    )

    if @cancellation
      @cancellation.destroy!
      respond_to do |format|
        format.html { redirect_to calendar_index_path, notice: 'Cancellation removed successfully.' }
        format.json { render json: { success: true, message: 'Cancellation removed successfully.' } }
      end
    else
      respond_to do |format|
        format.html { redirect_to calendar_index_path, alert: 'No cancellation found.' }
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
