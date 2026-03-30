# frozen_string_literal: true

module Trainers
  class UsersController < Trainers::ApplicationController
    def index
      @users = current_user.trainer.users.order(:name)
    end

    def show
      @user = current_user.trainer.users.find(params[:id])
      authorize! :read, @user
    end
  end
end
