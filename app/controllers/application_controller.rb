class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # CanCanCan authorization
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  private

  def require_complete_profile
    redirect_to edit_profile_path, alert: t('flashes.profile.complete_required') if current_user && !current_user.complete_profile?
  end

  def current_user
    Current.session&.user
  end
  helper_method :current_user

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
