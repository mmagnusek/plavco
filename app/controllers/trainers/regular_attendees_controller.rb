# frozen_string_literal: true

module Trainers
  class RegularAttendeesController < Trainers::ApplicationController
    before_action :set_slot

    def create
      rp = regular_attendee_params
      user = current_user.trainer.users.find(rp[:user_id])
      @regular_attendee = @slot.regular_attendees.build(user: user, from: rp[:from])
      authorize! :create, @regular_attendee

      if @regular_attendee.save
        redirect_to trainer_slot_path(@slot), notice: t('flashes.trainers.regular_attendees.created')
      else
        redirect_to trainer_slot_path(@slot), alert: @regular_attendee.errors.full_messages.to_sentence
      end
    end

    def edit
      @regular_attendee = @slot.regular_attendees.find(params[:id])
      authorize! :update, @regular_attendee
      return if ensure_not_already_ended!
    end

    def update
      @regular_attendee = @slot.regular_attendees.find(params[:id])
      authorize! :update, @regular_attendee
      return if ensure_not_already_ended!

      attrs = regular_attendee_update_params
      if attrs[:to].blank?
        @regular_attendee.assign_attributes(attrs)
        @regular_attendee.errors.add(:to, :blank)
        render :edit, status: :unprocessable_content
        return
      end

      if @regular_attendee.update(attrs)
        redirect_to trainer_slot_path(@slot), notice: t('flashes.trainers.regular_attendees.updated')
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def ensure_not_already_ended!
      return false unless @regular_attendee.to.present?

      redirect_to trainer_slot_path(@slot), alert: t('flashes.trainers.regular_attendees.already_ended')
      true
    end

    def set_slot
      @slot = current_user.trainer.slots.find(params[:slot_id])
    end

    def regular_attendee_params
      params.require(:regular_attendee).permit(:user_id, :from)
    end

    def regular_attendee_update_params
      params.require(:regular_attendee).permit(:to)
    end
  end
end
