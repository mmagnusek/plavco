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

  def change_trainer
    trainer = current_user.trainers.find(params[:trainer_id])
    Current.session.update(trainer: trainer)
    redirect_back fallback_location: calendar_index_path,
                  notice: t('flashes.profile.trainer_changed', trainer: trainer.name)
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :locale)
  end
end
