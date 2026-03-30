# frozen_string_literal: true

module Trainers
  class SlotsController < InheritedResources::Base
    defaults resource_class: Slot, collection_name: 'slots', instance_name: 'slot'
    respond_to :html

    def index
      authorize! :read, Slot
      super
    end

    def show
      authorize! :read, resource
      @regular_attendees = resource.regular_attendees.includes(:user).ordered_for_display
      @new_regular_attendee = resource.regular_attendees.build
      super
    end

    def new
      authorize! :create, Slot
      super
    end

    def create
      authorize! :create, Slot
      super do |success, failure|
        success.html { redirect_to trainer_slot_path(resource), notice: t('flashes.trainers.slots.created') }
        failure.html { render :new, status: :unprocessable_entity }
      end
    end

    def edit
      authorize! :update, resource
      super
    end

    def update
      authorize! :update, resource
      super do |success, failure|
        success.html { redirect_to trainer_slot_path(resource), notice: t('flashes.trainers.slots.updated') }
        failure.html { render :edit, status: :unprocessable_entity }
      end
    end

    def destroy
      authorize! :destroy, resource
      super do |success, failure|
        success.html { redirect_to trainer_slots_path, notice: t('flashes.trainers.slots.destroyed') }
        failure.html { redirect_to trainer_slot_path(resource), alert: t('flashes.trainers.slots.destroy_failed') }
      end
    end

    protected

    def slot_params
      params.fetch(:slot, {}).permit(:day_of_week, :starts_at, :ends_at, :max_participants)
    end

    def begin_of_association_chain
      current_user.trainer
    end

    def collection
      get_collection_ivar || set_collection_ivar(
        end_of_association_chain.ordered_by_day_and_time.includes(regular_attendees: :user)
      )
    end
  end
end
