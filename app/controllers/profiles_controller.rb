class ProfilesController < ApplicationController
  before_action :require_authentication

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.profile_update!
    if @user.update(user_params)
      redirect_to root_path, notice: 'Profile updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone)
  end
end
