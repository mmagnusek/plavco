class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # CanCanCan authorization
  include CanCan::ControllerAdditions

  # Uncomment to enforce authorization checks on all actions
  # check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  private

  # Override this method to set the current user
  # For now, returns the first user for testing
  # TODO: Replace with actual authentication (e.g., Devise)
  def current_user
    @current_user ||= User.where(admin: false).first
  end
  helper_method :current_user

  # Required by CanCanCan
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
