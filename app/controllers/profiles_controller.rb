class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.profile_update!
    if @user.update(user_params)
      redirect_to root_path, notice: t('flashes.profile.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :locale)
  end
end
