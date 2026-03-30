# frozen_string_literal: true

module Trainers
  class ApplicationController < ::ApplicationController
    layout 'trainers'

    before_action :authorize_trainer_portal!
    before_action :sync_session_trainer!

    private

    def authorize_trainer_portal!
      unless current_user&.trainer?
        redirect_to root_path, alert: I18n.t('trainers.flash.only_trainers')
        return
      end

      authorize! :access, :trainer_portal
    end

    def sync_session_trainer!
      return unless current_user.trainer
      return if Current.session.trainer_id == current_user.trainer_id

      Current.session.update!(trainer: current_user.trainer)
    end
  end
end
